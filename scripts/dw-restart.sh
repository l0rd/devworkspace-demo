#!/bin/bash

set -o nounset
set -o errexit

NAMESPACE=${1}
DW_NAME=$(kubectl get -n "${NAMESPACE}" dw -o json | jq -r '.items[0].metadata.name') # Assuming there is only one DW

echo "Restarting the DevWorksapce ${DW_NAME} in namespace ${NAMESPACE}"

kubectl patch dw "${DW_NAME}" -n "${NAMESPACE}" --type='merge' -p '{"spec":{"started":false}}'
sleep 1
kubectl patch dw "${DW_NAME}" -n "${NAMESPACE}" --type='merge' -p '{"spec":{"started":true}}'
