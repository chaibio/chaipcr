###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
window.ChaiBioTech.ngApp

.directive 'testInProgress', [
  'Status'
  '$interval'
  'Experiment'
  'AmplificationChartHelper'
  'TestInProgressHelper'
  (Status, $interval, Experiment, AmplificationChartHelper, TestInProgressHelper) ->
    restrict: 'EA'
    scope:
      experimentId: '='
    replace: true
    templateUrl: 'app/views/directives/test-in-progress.html'
    link: ($scope, elem) ->

      $scope.completionStatus = null
      $scope.is_holding = false

      updateIsHolding = (data) ->
        $scope.is_holding = TestInProgressHelper.set_holding(data, $scope.experiment)

      updateData = (data) ->

        if (!$scope.completionStatus and (data?.experiment_controller?.machine.state is 'idle' or data?.experiment_controller?.machine.state is 'complete') or !$scope.experiment) and $scope.experimentId
          Experiment.get(id: $scope.experimentId).then (resp) ->
            $scope.data = data
            $scope.completionStatus = resp.experiment.completion_status
            $scope.experiment = resp.experiment
        else
          $scope.data = data

      if Status.getData() then updateData Status.getData()

      $scope.$on 'status:data:updated', (e, data) ->
        updateData data
        updateIsHolding data
        $scope.timeRemaining = TestInProgressHelper.timeRemaining(data)

      $scope.barWidth = ->
        if $scope.data and $scope.data.experiment_controller.machine.state is 'running'
          exp = $scope.data.experiment_controller.experiment
          width = exp.run_duration/exp.estimated_duration
          if width > 1 then width = 1

          width
        else
          0

]