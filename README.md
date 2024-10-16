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

Open PR `Release - update bundle version` and update [patch_csv.yaml](./bundle-patch/patch_csv.yaml) by submitting a PR with follow-up changes:
1. `spec.version` with the current version e.g. `jaeger-operator.v1.58.0`
1. `spec.name` with the current version e.g. `jaeger-operator.v1.58.0`
1. `spec.replaces` with [the previous shipped version](https://catalog.redhat.com/software/containers/rhosdt/opentelemetry-operator-bundle/615618406feffc5384e84400) of CSV e.g. `jaeger-operator.v1.57.0-1`
1. `metadata.extra_annotations.olm.skipRange` with the version being productized e.g. `'>=0.33.0 <1.58.0'`
1. Update `release` and `version` labels in [bundle dockerfile](./Dockerfile.bundle)

Once the PR is merged and bundle is built. Open another PR `Release - update catalog` with:
* Updated [catalog template](./catalog/catalog-template.json) with the new bundle (get the bundle pullspec from [Konflux](https://console.redhat.com/application-pipeline/workspaces/rhosdt/applications/jaeger/components/jaeger-bundle)):
   ```bash
    opm alpha render-template basic --output yaml --migrate-level bundle-object-to-csv-metadata catalog/catalog-template.yaml > catalog/jaeger-product-4.17/catalog.yaml && \
    opm alpha render-template basic --output yaml catalog/catalog-template.yaml > catalog/jaeger-product/catalog.yaml && \
    sed -i 's#quay.io/redhat-user-workloads/rhosdt-tenant/otel/jaeger-bundle#registry.redhat.io/rhosdt/jaeger-operator-bundle#g' catalog/jaeger-product-4.17/catalog.yaml  && \
    sed -i 's#quay.io/redhat-user-workloads/rhosdt-tenant/otel/jaeger-bundle#registry.redhat.io/rhosdt/jaeger-operator-bundle#g' catalog/jaeger-product/catalog.yaml  && \
    opm validate catalog/jaeger-product && \
    opm validate catalog/jaeger-product-4.17
   ```
