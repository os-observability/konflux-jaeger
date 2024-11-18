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
* Updated [catalog template](./catalog/catalog-template.yaml) with the new bundle (get the bundle pullspec from [Konflux](https://console.redhat.com/application-pipeline/workspaces/rhosdt/applications/jaeger/components/jaeger-bundle)):
   ```bash
    opm alpha render-template basic --output yaml --migrate-level bundle-object-to-csv-metadata catalog/catalog-template.yaml > catalog/jaeger-product-4.17/catalog.yaml && \
    opm alpha render-template basic --output yaml catalog/catalog-template.yaml > catalog/jaeger-product/catalog.yaml && \
    sed -i 's#quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-bundle#registry.redhat.io/rhosdt/jaeger-operator-bundle#g' catalog/jaeger-product-4.17/catalog.yaml  && \
    sed -i 's#quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-bundle#registry.redhat.io/rhosdt/jaeger-operator-bundle#g' catalog/jaeger-product/catalog.yaml  && \
    opm validate catalog/jaeger-product && \
    opm validate catalog/jaeger-product-4.17
   ```

## Test locally

Images can be found at https://quay.io/organization/redhat-user-workloads (search for `rhosdt-tenant/jaeger`).

### Deploy bundle

```bash
operator-sdk olm install
# get latest image pullspec from https://console.redhat.com/application-pipeline/workspaces/rhosdt/applications/jaeger/components/jaeger-bundle-quay
operator-sdk run bundle quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-bundle-quay@sha256:10b2bfbb9bd4b0dd6ae5093d95f9766862c6148a5f88139ccb99dc413d4a32c1
operator-sdk cleanup jaeger-product
```

### Extract file based catalog from OpenShift index

```bash
podman cp $(podman create --name tc registry.redhat.io/redhat/redhat-operator-index:v4.17):/configs/jaeger-product jaeger-product-4.17 && podman rm tc
opm migrate jaeger-product-4.17 jaeger-product-4.17-migrated
opm alpha convert-template basic --output yaml ./jaeger-product-4.17-migrated/jaeger-product/catalog.json > catalog/catalog-template.yaml
```
