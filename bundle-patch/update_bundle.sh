#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export JAEGER_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-collector@sha256:0bc8e7dcaa9d837fe2416eb69de659dd2949a528e8395c9b2430e969784b618b"
# Separate due to merge conflicts
export JAEGER_AGENT_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-agent@sha256:6c1da8adfa47bfc023133d9a91e9b48862f97d2d4fd0dc1799e52a8d8ed5fd5a"
# Separate due to merge conflicts
export JAEGER_INGESTER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-ingester@sha256:50840f62efa5503badb00176b105fcbb202918ca6da2b66e06d1d44988699c8a"
# Separate due to merge conflicts
export JAEGER_QUERY_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-query@sha256:2d6aaa213f6f7153478d932cef03837fd1a62ba8ecf0049db5608f1f9cbc4e4a"
# Separate due to merge conflicts
export JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-all-in-one@sha256:ae14102c3de2b41abdccde141c45af071ad8631f87547206cec893908cce80b5"
# Separate due to merge conflicts
export JAEGER_ROLLOVER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-rollover@sha256:eb3ceeaa509e8db3c98176b05dbdb22d6e88f946437320c6b18900ff43a99551"
# Separate due to merge conflicts
export JAEGER_INDEX_CLEANER_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-es-index-cleaner@sha256:943c6da86a1e71e0ff4b3af8acbd660ac8de3d7b1a4b8da6268dafeeaf8a840a"
# Separate due to merge conflicts
export JAEGER_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/jaeger/jaeger-operator@sha256:2116ed082118c44914fd1309ed1c8d0f4aaf006903ba6eb40b2637de2b66a74e"
# Separate due to merge conflicts
# TODO, we used to set the proxy image per OCP version
export OSE_KUBE_RBAC_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-kube-rbac-proxy@sha256:7efeeb8b29872a6f0271f651d7ae02c91daea16d853c50e374c310f044d8c76c"
export OSE_OAUTH_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-oauth-proxy@sha256:234af927030921ab8f7333f61f967b4b4dee37a1b3cf85689e9e63240dd62800"

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
