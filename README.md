# Tekton Dashboard

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/kubernetes/dashboard/blob/master/LICENSE)

Tekton Dashboard is a general purpose, web-based UI for Tekton Pipelines. It allows users to manage and view Tekton Pipeline and Task runs and the resources involved in their creation, execution, and completion.

![Dashboard UI workloads page](docs/dashboard-ui.png)

## Pre-requisites
[Tekton Pipelines](https://github.com/tektoncd/pipeline) must be installed in order to use the Tekton Dashboard. Instructions to install Tekton Pipelines can be found [here](https://github.com/tektoncd/pipeline/blob/master/docs/install.md).

## Install Dashboard
The Tekton Dashboard has a hosted image located at gcr.io/tekton-nightly/dashboard:latest
To install the latest dashboard using this image:
```
kubectl apply -f config/release/gcr-tekton-dashboard.yaml
```

Alternatively, the dashboard can be installed through the same GitHub release asset:
```
curl -L https://github.com/tektoncd/dashboard/releases/download/v0/gcr-tekton-dashboard.yaml | kubectl apply -f -
```

Development installation of the Dashboard uses `ko`:
```
sh
$ docker login
$ export KO_DOCKER_REPO=docker.io/<mydockername>
$ ./install-dev.sh
```

The `install-dev.sh` script will build and push an image of the Tekton Dashboard to the Docker registry which you are logged into. Any Docker registry will do, but in this case it will push to Dockerhub. It will also apply the Pipeline0 definition and task: this allows you to import Tekton resources from Git repositories. It will also build the static web content using `npm` scripts.

## Install on Minishift

1. Install [tektoncd-pipeline-operator](https://github.com/openshift/tektoncd-pipeline-operator#deploy-openshift-pipelines-operator-on-minikube-for-testing)
2. [Checkout](https://github.com/tektoncd/dashboard/blob/master/DEVELOPMENT.md#checkout-your-fork) the repository
3. Install deployment config `$oc process -f config/templates/deploy.yaml | oc apply -f-`
4. Install build config `$oc process -f config/templates/build.yaml | oc apply -f-`

## Accessing the Dashboard
The Dashboard has can be accessed through its ClusterIP Service by running `kubectl proxy`. Assuming default is the install namespace for the dashboard, you can access the web UI at `localhost:8001/api/v1/namespaces/default/services/tekton-dashboard:http/proxy/`

## Want to contribute

We are so excited to have you!

- See [CONTRIBUTING.md](https://github.com/tektoncd/pipeline/blob/master/CONTRIBUTING.md) for an overview of our processes
- See [DEVELOPMENT.md](https://github.com/tektoncd/dashboard/blob/master/DEVELOPMENT.md) for how to get started