#!/usr/bin/env bash

set -eu
set -a && . bundle.env && set +a

if [[ $REGISTRY == "registry.redhat.io" || $REGISTRY == "registry.stage.redhat.io" ]]; then
  JAEGER_COLLECTOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-collector-rhel8@${JAEGER_COLLECTOR_IMAGE_PULLSPEC:(-71)}"
  JAEGER_AGENT_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-agent-rhel8@${JAEGER_AGENT_IMAGE_PULLSPEC:(-71)}"
  JAEGER_INGESTER_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-ingester-rhel8@${JAEGER_INGESTER_IMAGE_PULLSPEC:(-71)}"
  JAEGER_QUERY_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-query-rhel8@${JAEGER_QUERY_IMAGE_PULLSPEC:(-71)}"
  JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-all-in-one-rhel8@${JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC:(-71)}"
  JAEGER_ES_ROLLOVER_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-es-rollover-rhel8@${JAEGER_ES_ROLLOVER_IMAGE_PULLSPEC:(-71)}"
  JAEGER_ES_INDEX_CLEANER_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-es-index-cleaner-rhel8@${JAEGER_ES_INDEX_CLEANER_IMAGE_PULLSPEC:(-71)}"
  JAEGER_OPERATOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/jaeger-rhel8-operator@${JAEGER_OPERATOR_IMAGE_PULLSPEC:(-71)}"
fi


export CSV_FILE=manifests/jaeger-operator.clusterserviceversion.yaml

sed -i "s#jaeger-collector-container-pullspec#$JAEGER_COLLECTOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-agent-container-pullspec#$JAEGER_AGENT_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-query-container-pullspec#$JAEGER_QUERY_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-ingester-container-pullspec#$JAEGER_INGESTER_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-allinone-container-pullspec#$JAEGER_ALL_IN_ONE_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-es-rollover-container-pullspec#$JAEGER_ES_ROLLOVER_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#jaeger-es-index-cleaner-container-pullspec#$JAEGER_ES_INDEX_CLEANER_IMAGE_PULLSPEC#g" patch_csv.yaml
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
