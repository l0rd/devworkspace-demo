[![Contribute (nightly)](https://img.shields.io/static/v1?label=nightly%20Che&message=for%20maintainers&logo=eclipseche&color=FDB940&labelColor=525C86)](https://che-dogfooding.apps.che-dev.x6e0.p1.openshiftapps.com/#https://github.com/l0rd/devworkspace-demo?che-editor=che-incubator/che-code/insiders)

# Preparation

### Install the DevWorkspace Operator
It can be installed as a standalone operator or it gets installed with the Web Terminal or OpenShift Dev Spaces. The following instructions have been tested on Red Hat Developer Sandbox where the DevWorkspace Operator v0.15 is currently installed.

### Create a namespace and Deploy the editors definitions there

```bash
# Deploy the DevWorkspace Templates that 
# define a basic editor based on ttyd
# https://github.com/tsl0922/ttyd
# and an editor based on nightly VS Code
# https://github.com/che-incubator/che-code
$ oc new-project dw-demo && kubectl apply -f ./ttyd.yml && kubectl apply -f ./vs-code.yml
```

### Create a secret with the kube context that we want to add in the workspaces (optional)

```bash
# This is optional. If executed the demo 
# can be run from the editors (inception mode ;-))
$ ./0-kubeconfig-secret.sh
```

### Build the container image with the devtools (optional)

```bash
# This is optional.
$ IMAGE="quay.io/mloriedo/universal-developer-image:ubi8-dw-demo"
$ docker build -t "${IMAGE}" -f Dockerfile.dev .
$ docker push "${IMAGE}"
```


# Run the demo

```bash
# STEP 1
# Create the terminal-based devworkspace
# and wait until its in the "Running" state
$ kubectl apply -f ./1-dw-basic.yaml && kubectl get --watch -n dw-demo dw microservices-demo
microservices-demo   workspaceacb3d9378ab94f72   Starting   Waiting for workspace deployment
microservices-demo   workspaceacb3d9378ab94f72   Starting   Waiting for editor to start
microservices-demo   workspaceacb3d9378ab94f72   Starting   Waiting for editor to start
microservices-demo   workspaceacb3d9378ab94f72   Running    https://workspaceacb3d9378ab94f72.apps.che-dev.x6e0.p1.openshiftapps.com/ttyd/

# STEP 2
# Create a config map that includes a .bashrc 
# with a nicer $PS1. The DevWorkspace is restarted
# and the .bashrc will be auto-mounted in the new
# container.
$ kubectl apply -f ./2-bashrc-cm.yaml && ./dw-restart.sh dw-demo
configmap/dotfiles-config created
Restarting the DevWorksapce microservices-demo in namespace dw-demo
devworkspace.workspace.devfile.io/microservices-demo patched
devworkspace.workspace.devfile.io/microservices-demo patched

# STEP 3
# If we change the source code and try to push (or just 
# commit) we will get an error.
# To automatically setup git we can use a secret with the
# credentials and a configmap with the gitconfig.
$ GITHUB_LOGIN=<your-github-username> \
  GITHUB_TOKEN=<your-github-token> \
  GIT_USER_NAME=<your-git-config-user-name> \
  GIT_USER_EMAIL=<your-git-config-user-email> \
  ./3-git-setup.sh && \
  ./dw-restart.sh dw-demo
secret/git-credentials created
configmap/git-config created
Restarting the DevWorksapce microservices-demo in namespace dw-demo
devworkspace.workspace.devfile.io/microservices-demo patched
devworkspace.workspace.devfile.io/microservices-demo patched

# STEP 4
# Add more components in the devworkspace to test the
# frontend comunicating with the underlying microservices.
$ kubectl apply -f ./4-dw-microservices.yaml

# STEP 5
# Run the DW with VS Code.
$ kubectl apply -f ./5-dw-complete.yaml
```

# Cleanup

```
NAMESPACE=dw-demo
kubectl delete -n "${NAMESPACE}" dw microservices-demo
kubectl delete -n "${NAMESPACE}" cm git-config
kubectl delete -n "${NAMESPACE}" secret git-credentials
kubectl delete -n "${NAMESPACE}" cm dotfiles-config
kubectl delete -n "${NAMESPACE}" secret kube-config
kubectl delete -n "${NAMESPACE}" dwt vs-code ttyd
oc delete project "${NAMESPACE}"
```