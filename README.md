# konflux-jaeger

This repository contains Konflux configuration to build Red Hat build OpenShift distributed tracing platform (Jaeger).

## Build locally

```bash
docker login brew.registry.redhat.io -u
docker login registry.redhat.io -u

git submodule update --init --recursive

podman build -t docker.io/user/jaeger-operator:$(date +%s) -f Dockerfile.operator 
```

## Release
### Application
Update all base images (merge renovatebot PRs).

Create a PR `Release - update upstream sources x.y`:
1. Update git submodules with upstream versions
   **Note:** If you use a forked repository instead of upstream, you must sync the git tags.
   The version information is set dynamically using `git describe --tags` in the Dockerfile, and is crucial for e.g. the upgrade process of the operator.

### Bundle
Wait for renovatebot to create PRs to update the hash in the `bundle-patch/update_bundle.sh` file, and merge all of them.

Create a PR `Release - update bundle version x.y` and update [patch_csv.yaml](./bundle-patch/patch_csv.yaml) by submitting a PR with follow-up changes:
1. `metadata.name` with the current version e.g. `jaeger-operator.v1.58.0-1`
1. `metadata.extra_annotations.olm.skipRange` with the version being productized e.g. `'>=0.33.0 <1.58.0-1'`
1. `spec.version` with the current version e.g. `jaeger-operator.v1.58.0-1`
1. `spec.replaces` with [the previous shipped version](https://catalog.redhat.com/software/containers/rhosdt/jaeger-operator-bundle/613b50f3a052bb39f2c5f31e) of CSV e.g. `jaeger-operator.v1.57.0-1`
1. Update `release`, `version` and `com.redhat.openshift.versions` (minimum OCP version) labels in [bundle dockerfile](./Dockerfile.bundle)
1. Verify diff of upstream and downstream ClusterServiceVersion
   ```bash
   podman build -t jaeger-bundle -f Dockerfile.bundle . && podman cp $(podman create jaeger-bundle):/manifests/jaeger-operator.clusterserviceversion.yaml .
   git diff --no-index jaeger-operator/bundle/manifests/jaeger-operator.clusterserviceversion.yaml jaeger-operator.clusterserviceversion.yaml
   rm jaeger-operator.clusterserviceversion.yaml
   ```

### Catalog
Once the PR is merged and bundle is built, create another PR `Release - update catalog x.y` with:
* Updated [catalog template](./catalog/catalog-template.yaml) with the new bundle (get the bundle pullspec from `kubectl get component jaeger-bundle -o yaml`):
   ```bash
   opm alpha render-template basic --output yaml catalog/catalog-template.yaml > catalog/jaeger-product/catalog.yaml && \
   opm alpha render-template basic --output yaml --migrate-level bundle-object-to-csv-metadata catalog/catalog-template.yaml > catalog/jaeger-product-4.17/catalog.yaml && \
   sed -i 's#quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-bundle#registry.redhat.io/rhosdt/jaeger-operator-bundle#g' catalog/jaeger-product/catalog.yaml  && \
   sed -i 's#quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-bundle#registry.redhat.io/rhosdt/jaeger-operator-bundle#g' catalog/jaeger-product-4.17/catalog.yaml  && \
   opm validate catalog/jaeger-product && \
   opm validate catalog/jaeger-product-4.17
   ```

## Test locally

Images can be found at https://quay.io/organization/redhat-user-workloads (search for `rhosdt-tenant/jaeger`).

### Deploy Image Digest Mirror Set

Before using the bundle or catalog method for installing the operator, the ImageDigestMirrorSet needs to be created. The bundle and catalog uses pullspecs from `registry.redhat.io` which are not available before the release. Therefore the images need to be re-mapped.

From https://konflux.pages.redhat.com/docs/users/getting-started/building-olm-products.html#releasing-a-fbc-component

```yaml
kubectl apply -f - <<EOF
apiVersion: config.openshift.io/v1
kind: ImageDigestMirrorSet
metadata:
  name: jaeger-idms
spec:
  imageDigestMirrors:
  - source: registry.redhat.io/rhosdt/jaeger-rhel8-operator
    mirrors:
      - quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-operator
  - source: registry.redhat.io/rhosdt/jaeger-collector-rhel8
    mirrors:
      - quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-collector
  - source: registry.redhat.io/rhosdt/jaeger-query-rhel8
    mirrors:
      - quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-query
  - source: registry.redhat.io/rhosdt/jaeger-agent-rhel8
    mirrors:
      - quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-agent
  - source: registry.redhat.io/rhosdt/jaeger-ingester-rhel8
    mirrors:
      - quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-ingester
  - source: registry.redhat.io/rhosdt/jaeger-all-in-one-rhel8
    mirrors:
      - quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-all-in-one
  - source: registry.redhat.io/rhosdt/jaeger-es-index-cleaner-rhel8
    mirrors:
      - quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-index-cleaner
  - source: registry.redhat.io/rhosdt/jaeger-es-rollover-rhel8
    mirrors:
      - quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-rollover
  - source: registry.redhat.io/rhosdt/jaeger-operator-bundle
    mirrors:
      - quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-bundle
EOF
```

### Deploy bundle

get latest pullspec from `kubectl get component jaeger-bundle-main -o yaml`, then run:
```bash
kubectl create namespace openshift-distributed-tracing
operator-sdk run bundle -n openshift-distributed-tracing quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-bundle@sha256:33de16a561ce5bccff0f2b9de19ce65cd77191b8b69f3e943e4efcdf68572896
operator-sdk cleanup -n openshift-distributed-tracing jaeger-product
```
### Deploy catalog

Get catalog for specific version from [Konflux](https://console.redhat.com/application-pipeline/workspaces/rhosdt/applications/jaeger-fbc-v4-15-main/components/jaeger-fbc-v4-15-main)

```yaml
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
   name: konflux-catalog-jaeger
   namespace: openshift-marketplace
spec:
   sourceType: grpc
   image: quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-fbc-v4-15:e962273c6224621bd225d42c6cd843af6ee57b34
   displayName: Konflux Catalog Jaeger
   publisher: grpc
EOF

kubectl get pods -w -n openshift-marketplace
kubectl delete CatalogSource konflux-catalog-jaeger -n openshift-marketplace
```

`Konflux catalog Jaeger` menu should appear in the OCP console under Operators->OperatorHub.

### Extract file based catalog from OpenShift index

```bash
podman cp $(podman create --name tc registry.redhat.io/redhat/redhat-operator-index:v4.17):/configs/jaeger-product jaeger-product-4.17 && podman rm tc
opm migrate jaeger-product-4.17 jaeger-product-4.17-migrated
opm alpha convert-template basic --output yaml ./jaeger-product-4.17-migrated/jaeger-product/catalog.json > catalog/catalog-template.yaml
```
