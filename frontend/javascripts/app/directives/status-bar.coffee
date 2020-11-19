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
window.App.directive 'statusBar', [
  'Experiment'
  '$state'
  'TestInProgressHelper'
  '$timeout'
  '$window'
  (Experiment, $state, TestInProgressHelper, $timeout, $window) ->

    restrict: 'EA'
    replace: true
    templateUrl: 'app/views/directives/status-bar.html'
    link: ($scope, elem, attrs) ->


      experiment_id = null
      $document = angular.element(document)
      inputFocus = elem.find('input')
      stopping = false
      $scope.truncate = Experiment.truncateName

      $scope.show = ->
        if $scope.state isnt 'idle' then (!!$scope.status and !!$scope.footer_experiment) else !!$scope.status

      getExperiment = (cb) ->
        return if !experiment_id
        Experiment.get(id: experiment_id).then (data) ->
          cb data.experiment

      $scope.$watch 'experimentId', (id) ->
        return if !id
        getExperiment (exp) ->
          $scope.footer_experiment = exp

      $scope.is_holding = false

      $scope.goToTestKit = ->
        switch $scope.footer_experiment.guid
          when "chai_coronavirus_env_kit"
            $state.go('coronavirus-env.experiment-running', {id: $scope.footer_experiment.id})
          when "chai_covid19_surv_kit"
            $state.go('covid19-surv.experiment-running', {id: $scope.footer_experiment.id})
          when "pika_4e_kit"
            $state.go('pika_test.experiment-running', {id: $scope.footer_experiment.id})

      $scope.$on 'status:data:updated', (e, data, oldData) ->
        return if !data
        return if !data.experiment_controller
        $scope.state = data.experiment_controller.machine.state
        $scope.thermal_state = data.experiment_controller.machine.thermal_state
        $scope.oldState = oldData?.experiment_controller?.machine?.state || 'NONE'

        if ((($scope.oldState isnt $scope.state or !$scope.footer_experiment))) and experiment_id
          getExperiment (exp) ->
            $scope.footer_experiment = exp
            $scope.status = data
            $scope.is_holding = TestInProgressHelper.set_holding(data, exp)
        else
          $scope.status = data
          $scope.is_holding = TestInProgressHelper.set_holding(data, $scope.footer_experiment)

        $scope.timeRemaining = TestInProgressHelper.timeRemaining(data)

        if ($scope.state isnt 'idle' and !experiment_id and data.experiment_controller?.experiment?.id)
          experiment_id = data.experiment_controller.experiment.id
          getExperiment (exp) ->
            $scope.footer_experiment = exp

        if $scope.state is 'idle' and $scope.oldState isnt 'idle'
          $scope.footer_experiment = null
          experiment_id = null

      $scope.getDuration = ->
        return 0 if !$scope?.experiment?.completed_at
        Experiment.getExperimentDuration($scope.footer_experiment)

      $scope.stopExperiment = ->
        stopping = true
        Experiment.stopExperiment($scope.footer_experiment.id)
        .then ->
          $scope.footer_experiment = null
          $scope.stop_confirm_show = false
        .finally ->
          stopping = false

      $scope.resumeExperiment = ->
        Experiment.resumeExperiment($scope.footer_experiment.id)

      $scope.stopConfirm = ->
        $scope.stop_confirm_show = true
        $timeout ->
          inputFocus.focus()

      $scope.inputBlur = ->
        $timeout ->
          $scope.stop_confirm_show = false if !stopping
        , 250


]
