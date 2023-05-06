#!/bin/bash

set -o nounset
set -o errexit

GITHUB_LOGIN=${1:-${GITHUB_LOGIN}}
GITHUB_TOKEN=${2:-${GITHUB_TOKEN}}
GIT_USER_EMAIL=${3:-${GIT_USER_EMAIL}}
GIT_USER_NAME=${4:-${GIT_USER_NAME}}
GIT_WEBSITE="github.com"
CREDENTIALS=$(echo -n "https://${GITHUB_LOGIN}:${GITHUB_TOKEN}@${GIT_WEBSITE}" | base64 -w 0)
NAMESPACE="dw-demo"

kubectl apply -f - << EOF
apiVersion: v1
kind: Secret
metadata:
  name: git-credentials
  namespace: "${NAMESPACE}"
  annotations:
    controller.devfile.io/mount-path: /tmp/.git-credentials/
  labels:
    controller.devfile.io/git-credential: "true"
    controller.devfile.io/watch-secret: "true"
type: Opaque
data:
  credentials: ${CREDENTIALS}
EOF

kubectl apply -f - << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: git-config
  namespace: "${NAMESPACE}"
  annotations:
    controller.devfile.io/mount-as: subpath
    controller.devfile.io/mount-path: /etc/
  labels:
    controller.devfile.io/mount-to-devworkspace: "true"
    controller.devfile.io/watch-configmap: "true"
data:
  gitconfig: |
    [user]
      email = ${GIT_USER_EMAIL}
      name = ${GIT_USER_NAME}
    [alias]
      st = status
      co = checkout
      ci = commit
EOF
