#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export JAEGER_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-collector@sha256:7e868a070d0f2039db8445251c74594894af07b50c2b41f54c9d913543e9ada8"
# Separate due to merge conflicts
export JAEGER_AGENT_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-agent@sha256:e93f09abdb111f162b9faad393b509b5492ec27634b2ac03baad3d59f0f6092f"
# Separate due to merge conflicts
export JAEGER_INGESTER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-ingester@sha256:32a86ac42d84d768f84723cd53af25ebaf67958f9cfc93cf016c9da994a36b28"
# Separate due to merge conflicts
export JAEGER_QUERY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-query@sha256:44d208333c58a16efd872ca89d2af9d6e90258013334487c1027236516c34003"
# Separate due to merge conflicts
export JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-all-in-one@sha256:035c119d61b1e18c5219e67bd6e2c5e3fe060d8f5aa4f0d455f7e3fb62d8bab3"
# Separate due to merge conflicts
export JAEGER_ROLLOVER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-rollover@sha256:b795acdbe6981d0fae6d014a9b6a4e63c75558d6613922c329c579355a2bbb65"
# Separate due to merge conflicts
export JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-index-cleaner@sha256:e8278b8d3e0797948b500ab2a859547ed0563ce8990c050f041470682290a7cd"
# Separate due to merge conflicts
export JAEGER_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-operator@sha256:70b8c0cba7d933d0abebe739ea2b878785771e32c47c4dc7338d7a0ecb4bd14f"
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


