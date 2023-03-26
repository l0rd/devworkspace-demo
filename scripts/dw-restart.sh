#!/bin/bash

set -o nounset
set -o errexit

DW_NAME=$(kubectl get dw -o json | jq -r '.items[0].metadata.name') # Assuming there is only one DW

echo "Restarting the DevWorksapce ${DW_NAME}"

kubectl patch dw "${DW_NAME}" --type='merge' -p '{"spec":{"started":false}}'
sleep 1
kubectl patch dw "${DW_NAME}" --type='merge' -p '{"spec":{"started":true}}'
