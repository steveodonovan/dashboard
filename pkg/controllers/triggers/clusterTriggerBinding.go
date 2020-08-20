/*
Copyright 2020 The Tekton Authors
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
		http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package triggers

import (
	"github.com/tektoncd/dashboard/pkg/broadcaster"
	"github.com/tektoncd/dashboard/pkg/controllers/utils"
	logging "github.com/tektoncd/dashboard/pkg/logging"
	triggersinformer "github.com/tektoncd/triggers/pkg/client/informers/externalversions"
)

func NewClusterTriggerBindingController(sharedTriggersInformerFactory triggersinformer.SharedInformerFactory) {
	logging.Log.Debug("In NewClusterTriggerBindingController")

	utils.NewController(
		"ClusterTriggerBinding",
		sharedTriggersInformerFactory.Triggers().V1alpha1().ClusterTriggerBindings().Informer(),
		broadcaster.ClusterTriggerBindingCreated,
		broadcaster.ClusterTriggerBindingUpdated,
		broadcaster.ClusterTriggerBindingDeleted,
		nil,
	)
}