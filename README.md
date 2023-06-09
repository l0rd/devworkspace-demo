[![Contribute (nightly)](https://img.shields.io/static/v1?label=nightly%20Che&message=for%20maintainers&logo=eclipseche&color=FDB940&labelColor=525C86)](https://che-dogfooding.apps.che-dev.x6e0.p1.openshiftapps.com/#https://github.com/l0rd/devworkspace-demo?che-editor=che-incubator/che-code/insiders)

### [Supporting slides](https://docs.google.com/presentation/d/1ckYOEJTLBla_tcCqspecYOXXnH00FM--VqYlpI-srdk/edit#slide=id.g1288a653e6f_0_147)

# Preparation

## Install the DevWorkspace Operator
It can be installed as a standalone operator or it gets installed with the Web Terminal or OpenShift Dev Spaces. The following instructions have been tested with DevWorkspace Operator v0.19.

## Deploy the editors definitions

The following commands create the DevWorkspacesTemplates that define the IDEs: vim, vscode and intellij.

```bash
$ kubectl apply -f ./editors-contributions/
```

# Iteratively setup a cloud dev environment

## Containerized dev tools and source code 

```bash
kubectl apply -f ./dw1.yaml && \
  kubectl wait --for=condition=Ready dw/dw --timeout=300s && \
  export POD=`kubectl get pod -l "controller.devfile.io/devworkspace_name=dw" -o jsonpath={.items[].metadata.name}`
  printf "\nBuild in the remote dev environment:\n\n\tkubectl exec -ti ${POD} -- bash -c \'cd \${PROJECT_SOURCE} && mvn clean install\'\n\n"
```

## Add the IDE: VS Code

```bash
kubectl apply -f ./dw2.yaml && \
  kubectl wait --for=condition=Ready dw/dw --timeout=300s && \
  export IDE=`kubectl get dw dw -o jsonpath={.status.mainUrl}` && \
  printf "\nOpen VS Code in your browser with the following link:\n\n\t${IDE}\n\n"
```

And now vim...

```bash
kubectl patch dw dw \
     --type merge \
     -p '{ "spec": { "contributions": [ {"name": "editor", "kubernetes": { "name": "vim" } } ] } }'
```

And intelliJ...

```bash
kubectl patch dw dw \
     --type merge \
     -p '{ "spec": { "contributions": [ {"name": "editor", "kubernetes": { "name": "intellij" } } ] } }'
```

## Add pre-configured commands to build and test the application

`kubectl apply -f ./dw3.yaml && ./scripts/dw-restart.sh `

## Add a postgres container to run e2e tests

`kubectl apply -f ./dw4.yaml`

# Cloud dev environment configuration

## `kubeconfig`

```bash
$ ./auto-mount/kubeconfig.sh
```

## `bashrc` and `PS1`

```bash
$ kubectl apply -f ./auto-mount/bashrc.yaml 
```

## `gitconfig`

```bash
export GITHUB_LOGIN="<gh-login>"
export GITHUB_TOKEN="<gh-token>"
export GIT_USER_EMAIL="<email>"
export GIT_USER_NAME="<name>"

$ ./auto-mount/gitconfig.sh
```

## Persist `~/.m2`

TODO

# Change the dev tools image

## Build the container image with the devtools

```bash
$ IMAGE="quay.io/mloriedo/universal-developer-image:ubi8-dw-demo"
$ docker build -t "${IMAGE}" -f Dockerfile.dev .
$ docker push "${IMAGE}"
```

# Cleanup

```
NAMESPACE=dw-demo
kubectl delete dw dw
kubectl delete cm git-config dotfiles-config
kubectl delete secret git-credentials kube-config
kubectl delete dwt vs-code intellij vim
```
