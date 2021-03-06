#!/usr/bin/env bash

# Copyright 2018 The Tekton Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script calls out to scripts in tektoncd/plumbing to setup a cluster
# and deploy Tekton Pipelines to it for running integration tests.
export tekton_repo_dir=$(git rev-parse --show-toplevel)
source $(dirname $0)/e2e-common.sh

# Script entry point.

initialize $@

header "Setting up environment"

install_pipeline_crd
install_dashboard_backend

#Run the integration tests
header "Running e2e tests"

kubectl port-forward $(kubectl get pod -l app=tekton-dashboard -o name) 9097:9097 &
dashboardForwardPID=$!

#Apply permissions to be able to curl endpoints 
kubectl apply -f $tekton_repo_dir/test/test-rbac.yaml
kubectl apply -f $tekton_repo_dir/test/kaniko-build-task.yaml
kubectl apply -f $tekton_repo_dir/test/deploy-task-insecure.yaml
kubectl apply -f $tekton_repo_dir/test/Pipeline.yaml

#API configuration
APP_NS="default"
PIPELINE_NAME="simple-pipeline-insecure"
IMAGE_SOURCE_NAME="docker-image"
GIT_RESOURCE_NAME="git-source"
GIT_COMMIT="master"
REPO_NAME="go-hello-world"
REPO_URL="https://github.com/ncskier/go-hello-world" 
EXPECTED_RETURN_VALUE="Hello World! "
KSVC_NAME="go-hello-world"
REGISTRY="gcr.io/${E2E_PROJECT_ID}/${E2E_BASE_NAME}-e2e-img"

post_data='{
  "pipelinename": "'${PIPELINE_NAME}'",
  "imageresourcename": "'${IMAGE_SOURCE_NAME}'",
  "gitresourcename": "'${GIT_RESOURCE_NAME}'",
  "gitcommit": "'${GIT_COMMIT}'",
  "reponame": "'${REPO_NAME}'",
  "repourl": "'${REPO_URL}'",
  "registrylocation": "'$REGISTRY'",
  "serviceaccount": "'${APP_NS}'"
}'

#For loop to check 9097 exists 
dashboardExists=false
for i in {1..20}
do
  respF=$(curl -k  http://127.0.0.1:9097)
  if [ "$respF" != "" ]; then
    dashboardExists=true
    break
	else    
    sleep 5  
  fi
done

if [ "$dashboardExists" = "false" ]; then
  fail_test "Test Failure, Not able to curl the Dashboard"
fi 

curlNodePort="http://127.0.0.1:9097/v1/namespaces/${APP_NS}/pipelineruns/"
curl -X POST --header Content-Type:application/json -d "$post_data" $curlNodePort 

deploymentExist=false
for i in {1..30}
do
  wait=$(kubectl wait --for=condition=available deployments/go-hello-world --timeout=30s)
  if [ "$wait" = "deployment.extensions/go-hello-world condition met" ]; then
    deploymentExist=true
    break
  else    
    sleep 5  
  fi 
done

if [ "$deploymentExist" = "false" ]; then
  fail_test "Test Failure, go-hello-world deployment is not running"
fi 

kubectl port-forward $(kubectl get pod -l app=go-hello-world -o name) 8080 &
podForwardPID=$!

podCurled=false
for i in {1..20}
do
  resp=$(curl -k  http://127.0.0.1:8080)
  if [ "$resp" != "" ]; then
		echo "Response from pod is: $resp"
    podCurled=true
    if [ "$EXPECTED_RETURN_VALUE" = "$resp" ]; then
      echo "PipelineRun successfully executed"
      break
    else
      fail_test "PipelineRun error, returned an incorrect message: $resp"
    fi 
  else    
    sleep 5  
  fi 
done

if [ "$podCurled" = "false" ]; then
  fail_test "Test Failure, Not able to curl the pod"
fi

kill -9 $dashboardForwardPID
kill -9 $podForwardPID

success