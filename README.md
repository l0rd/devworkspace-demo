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

### Create a secret with the kube context that we want to add in the workspaces

```bash
$ ./0-kubeconfig-secret.sh
```

# Run the demo

```bash
# STEP 1
# Create the terminal-based devworkspace
# and wait for until its in Running state
$ kubectl apply -f ./1-dw-basic.yaml && kubectl get --watch dw microservices-demo
microservices-demo   workspaceacb3d9378ab94f72   Starting   Waiting for workspace deployment
microservices-demo   workspaceacb3d9378ab94f72   Starting   Waiting for editor to start
microservices-demo   workspaceacb3d9378ab94f72   Starting   Waiting for editor to start
microservices-demo   workspaceacb3d9378ab94f72   Running    https://workspaceacb3d9378ab94f72.apps.che-dev.x6e0.p1.openshiftapps.com/ttyd/

# STEP 2
# Creaet a config map that includes a .bashrc
# file 
# and wait for until its in Running state
$ kubectl apply -f ./2-bashrc-cm.yaml && ./dw-restart.sh
configmap/dotfiles-config created
devworkspace.workspace.devfile.io/microservices-demo patched
devworkspace.workspace.devfile.io/microservices-demo patched

```