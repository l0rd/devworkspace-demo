#!/bin/bash

set -o nounset
set -o errexit

NAMESPACE=${1:-dw-demo}
DW_NAME=$(kubectl get -n "${NAMESPACE}" dw -o json | jq -r '.items[0].metadata.name') # Assuming there is only one DW

echo "Deleting the DevWorksapce ${DW_NAME} in namespace ${NAMESPACE}"

kubectl delete dw "${DW_NAME}" -n "${NAMESPACE}"

