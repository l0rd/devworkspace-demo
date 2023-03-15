#!/bin/bash
set -euo pipefail

DW_NAME=${DW_NAME:-microservices-demo}
COMMAND_ID=$1

eval "$(kubectl get dw "${DW_NAME}" -o json | jq -r --arg COMMAND_ID "${COMMAND_ID}" '.spec.template.commands[] | select(.id == $COMMAND_ID) | .exec.commandLine')"