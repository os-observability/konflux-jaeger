#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export JAEGER_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-collector@sha256:36ba816aca295988bbb73a2a301181d6ac1bcd7e52cce46437eb87da18665ff6"
# Separate due to merge conflicts
export JAEGER_AGENT_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-agent@sha256:5b6b438a2d9ae76e05f6a803f55ea3d6bddefcf5b08bd77e269e51703c88e445"
# Separate due to merge conflicts
export JAEGER_INGESTER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-ingester@sha256:2e80dfb32eacef165d0ef7b9d261859b0b8900f56df5621c63d0a4ab4f95b58e"
# Separate due to merge conflicts
export JAEGER_QUERY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-query@sha256:bf474bea2818eb2bc246083a671e7f4d9228dd8ef7db3430782c1531a23d5de0"
# Separate due to merge conflicts
export JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-all-in-one@sha256:2ae05b48d25fa20607326b3860a19a2d63affa7afa798464bc4c40bb10974612"
# Separate due to merge conflicts
export JAEGER_ROLLOVER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-rollover@sha256:621af47f10d915a7434d1b932a19ef22bab2d8dcdc9749eb3347a84b21dbaf92"
# Separate due to merge conflicts
export JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-index-cleaner@sha256:f170876c56301d8713ea56ef8f3bb2f744cf271b40fe26b76f56d11c4341d187"
# Separate due to merge conflicts
export JAEGER_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-operator@sha256:77a4d171716b5fa2395997bd06e492bb0583abe138c5073170c2ed2935b2fb46"
# Separate due to merge conflicts
# TODO, we used to set the proxy image per OCP version
export OSE_KUBE_RBAC_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-kube-rbac-proxy@sha256:8204d45506297578c8e41bcc61135da0c7ca244ccbd1b39070684dfeb4c2f26c"
export OSE_OAUTH_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-oauth-proxy@sha256:4f8d66597feeb32bb18699326029f9a71a5aca4a57679d636b876377c2e95695"

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


