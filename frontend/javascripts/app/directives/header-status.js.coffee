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
window.App.directive 'headerStatus', [
  'Experiment'
  '$state'
  'Status'
  'TestInProgressHelper'
  '$rootScope'
  'expName'
  'ModalError'
  (Experiment, $state, Status, TestInProgressHelper, $rootScope, expName, ModalError) ->

    restrict: 'EA'
    replace: true
    transclude: true
    scope:
      experimentId: '=?'
    templateUrl: 'app/views/directives/header-status.html'
    link: ($scope, elem, attrs) ->

      experiment_id = null
      $scope.loading = true

      $scope.show = ->
        if attrs.experimentId then (experiment_id and $scope.status) else $scope.status

      getExperiment = (cb) ->
        return if !experiment_id
        $scope.loading = true
        Experiment.get(id: experiment_id).then (resp) ->
          $scope.loading = false
          cb resp.experiment if cb

      $scope.is_holding = false
	  
	 #$scope.$on 'start_confirm_show:false' ->
		 # $scope.start_confirm_show = false
	  	  
      $scope.$on 'status:data:updated', (e, data, oldData) ->
        return if !data
        return if !data.experiment_controller
        $scope.statusData = data
        $scope.state = data.experiment_controller.machine.state
        $scope.thermal_state = data.experiment_controller.machine.thermal_state
        $scope.oldState = oldData?.experiment_controller?.machine?.state || 'NONE'
        $scope.isCurrentExp = parseInt(data.experiment_controller.expriment?.id) is parseInt(experiment_id)

        if ((($scope.oldState isnt $scope.state or !$scope.experiment))) and experiment_id
          getExperiment (exp) ->
            $scope.experiment = exp
            $scope.status = data
            $scope.is_holding = TestInProgressHelper.set_holding(data, exp)
        else
          $scope.status = data
          $scope.is_holding = TestInProgressHelper.set_holding(data, $scope.experiment)

        $scope.timeRemaining = TestInProgressHelper.timeRemaining(data)
        $scope.timePercentage = TestInProgressHelper.timePercentage(data)

        #in progress
        if $scope.state isnt 'idle' and $scope.state isnt 'complete' and $scope.isCurrentExp
          $scope.backgroundStyle =
            background: "-webkit-linear-gradient(left,  #64b027 0%,#c6e35f #{$scope.timePercentage || 0}%,#5d8329 #{$scope.timePercentage || 0}%,#5d8329 100%)"
        else
          $scope.backgroundStyle = {}

      $scope.getDuration = ->
        return 0 if !$scope?.experiment?.completed_at
        Experiment.getExperimentDuration($scope.experiment)

      $scope.startExperiment = ->
        Experiment.startExperiment(experiment_id).then ->
          $scope.experiment.started_at = true
          getExperiment (exp) ->
            $scope.experiment = exp
            $rootScope.$broadcast 'experiment:started', experiment_id
            if $state.is('edit-protocol')
              max_cycle = Experiment.getMaxExperimentCycle($scope.experiment)
              $state.go('run-experiment', {'id': experiment_id, 'chart': 'amplification', 'max_cycle': max_cycle})
			  
      $scope.startConfirm = ->
        $scope.start_confirm_show = true	
		
      $scope.stopExperiment = ->
        Experiment.stopExperiment($scope.experiment.id)

      $scope.resumeExperiment = ->
        Experiment.resumeExperiment($scope.experiment.id)

      $scope.expName = (truncate_length) ->
        return Experiment.truncateName($scope.experiment.name, truncate_length)

      $scope.viewError = ->
        err =
          message: $scope.experiment.completion_message
          date: $scope.experiment.completed_at
        ModalError.open err

      $scope.$on 'expName:Updated', ->
        $scope.experiment?.name = expName.name

      $scope.$watch 'experimentId', (id) ->
        return if !id
        experiment_id = id
        getExperiment (exp) ->
          $scope.experiment = exp

]
