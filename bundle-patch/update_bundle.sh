#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export JAEGER_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-collector@sha256:f0e0f1e784b6c33f765b9bdb9d0d9ad89774bedf2d9da4003e584c8dbec78ae7"
# Separate due to merge conflicts
export JAEGER_AGENT_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-agent@sha256:48f1e890b7b061b08ec68120f4ba127d3564a42a3c62b3d1091b788c77b99d29"
# Separate due to merge conflicts
export JAEGER_INGESTER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-ingester@sha256:91688e2099f039e187b5eef25a39c62f0c1b1655232f27749e0710ed2d455055"
# Separate due to merge conflicts
export JAEGER_QUERY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-query@sha256:e84707f4a3fb28e87b76ebc25a68dea14294d19a745300c62d80838dae5d5d59"
# Separate due to merge conflicts
export JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-all-in-one@sha256:bacb19277d9f002bfdcabd3899a9f1cba78837312dff5d821a0242c352165d03"
# Separate due to merge conflicts
export JAEGER_ROLLOVER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-rollover@sha256:2bf60700c9fa7fc2cac6f9348e5b10641ad0d20ba47a6cdcb23c9ef661472cb3"
# Separate due to merge conflicts
export JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-index-cleaner@sha256:add5b22042b526af4ac9a621fbeb25679187e73d67bfa72f8ca24827527083dc"
# Separate due to merge conflicts
export JAEGER_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-operator@sha256:4c440eb87d37fa38648782c52faa9de1ef10381dbfafa943159f5818386ad8b5"
# Separate due to merge conflicts
# TODO, we used to set the proxy image per OCP version
export OSE_KUBE_RBAC_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-kube-rbac-proxy:latest@sha256:7efeeb8b29872a6f0271f651d7ae02c91daea16d853c50e374c310f044d8c76c"
export OSE_OAUTH_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-oauth-proxy:latest@sha256:234af927030921ab8f7333f61f967b4b4dee37a1b3cf85689e9e63240dd62800"

if [[ $REGISTRY == "registry.redhat.io" ||  $REGISTRY == "registry.stage.redhat.io" ]]; then
  JAEGER_COLLECTOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-collector-rhel8@${JAEGER_COLLECTOR_IMAGE_PULLSPEC:(-71)}"
  JAEGER_AGENT_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-agent-rhel8@${JAEGER_AGENT_IMAGE_PULLSPEC:(-71)}"
  JAEGER_INGESTER_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-ingester-rhel8@${JAEGER_INGESTER_IMAGE_PULLSPEC:(-71)}"
  JAEGER_QUERY_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-query-rhel8@${JAEGER_QUERY_IMAGE_PULLSPEC:(-71)}"
  JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-all-in-one-rhel8@${JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC:(-71)}"
  JAEGER_ROLLOVER_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-es-rollover-rhel8@${JAEGER_ROLLOVER_IMAGE_PULLSPEC:(-71)}"
  JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-es-index-cleaner-rhel8@${JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC:(-71)}"

  JAEGER_OPERATOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-rhel8-operator@${JAEGER_OPERATOR_IMAGE_PULLSPEC:(-71)}"
fi


export CSV_FILE=/manifests/jaeger-operator.clusterserviceversion.yaml

sed -i "s#jaeger-collector-container-pullspec#$JAEGER_COLLECTOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-agent-container-pullspec#$JAEGER_AGENT_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-query-container-pullspec#$JAEGER_QUERY_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-ingester-container-pullspec#$JAEGER_INGESTER_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-allinone-container-pullspec#$JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-rollover-container-pullspec#$JAEGER_ROLLOVER_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-index-cleaner-container-pullspec#$JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-operator-container-pullspec#$JAEGER_OPERATOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#ose-kube-rbac-proxy-container-pullspec#$OSE_KUBE_RBAC_PROXY_PULLSPEC#g" patch_csv.yaml
sed -i "s#ose-oauth-proxy-container-pullspec#$OSE_OAUTH_PROXY_PULLSPEC#g" patch_csv.yaml

#export AMD64_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="amd64")')
#export ARM64_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="arm64")')
#export PPC64LE_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="ppc64le")')
#export S390X_BUILT=$(skopeo inspect --raw docker://${JAEGER_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="s390x")')
export AMD64_BUILT=true
export ARM64_BUILT=true
export PPC64LE_BUILT=true
export S390X_BUILT=true

export EPOC_TIMESTAMP=$(date +%s)


# time for some direct modifications to the csv
python3 patch_csv.py
python3 patch_annotations.py
