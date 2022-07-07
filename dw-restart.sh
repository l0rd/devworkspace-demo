#!/bin/bash

DW_NAME=$(kubectl get dw -o json | jq -r '.items[0].metadata.name')
kubectl patch dw "${DW_NAME}" --type='merge' -p '{"spec":{"started":false}}'
sleep 1
kubectl patch dw "${DW_NAME}" --type='merge' -p '{"spec":{"started":true}}'
