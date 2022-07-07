#!/bin/bash

set -o nounset
set -o errexit

# Set the env variable KUBE_TOKEN with a valid token for current cluster
KUBE_TOKEN=$(kubectl config view --raw -o json | jq -r '.users[0].user.token')
KUBE_USER=$(oc whoami)
KUBE_NS=$(oc project -q)
KUBE_CONFIG=$(echo -n "apiVersion: v1
    clusters:
    - cluster:
        certificate-authority: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        server: https://kubernetes.default.svc
      name: localcluster
    contexts:
    - context:
        cluster: localcluster
        namespace: ${KUBE_NS}
        user: ${KUBE_USER}
      name: logged-user
    current-context: logged-user
    kind: Config
    users:
    - name: ${KUBE_USER}
      user:
        token: ${KUBE_TOKEN}")
KUBE_CONFIG_B64=$(echo "${KUBE_CONFIG}" | base64)

echo "kubectl apply -f - <<EOF
kind: Secret
apiVersion: v1
metadata:
  name: kube-config
  annotations:
    controller.devfile.io/mount-as: subpath
    controller.devfile.io/mount-path: /home/user/.kube
  labels:
    controller.devfile.io/mount-to-devworkspace: "true"
    controller.devfile.io/watch-secret: "true"
type: Opaque
data:
  config: |
    ${KUBE_CONFIG_B64}
EOF
"