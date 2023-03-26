#!/bin/bash

DW_NAME=${DW_NAME:-microservices-demo}
DW_POD_LABEL="controller.devfile.io/devworkspace_name=${DW_NAME}"
kubectl describe po -l "${DW_POD_LABEL}"