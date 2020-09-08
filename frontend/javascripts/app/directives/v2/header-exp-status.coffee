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

window.ChaiBioTech.ngApp.directive 'headerExpStatus', [
  'Experiment'
  '$state'
  'TestInProgressHelper'
  '$rootScope'
  'expName'
  'ModalError'
  '$location'
  '$timeout'
  'alerts'
  (Experiment, $state, TestInProgressHelper, $rootScope, expName, ModalError, $location, $timeout, alerts) ->

    restrict: 'EA'
    replace: true
    transclude: true
    scope:
      experimentId: '=?'
    templateUrl: 'app/views/directives/v2/header-exp-status.html'
    link: ($scope, elem, attrs, controller) ->

      INIT_LOADING = 2
      experiment_id = null
      $scope.expLoading = true
      $scope.statusLoading = INIT_LOADING
      $scope.start_confirm_show = false
      $scope.dataAnalysis = false
      $scope.isStarted = false
      counter = 0
      stringUrl = "run-experiment"
      if ($location.path().indexOf(stringUrl) == -1)
        $scope.dataAnalysis = true

      $scope.isLoading = () ->
        $scope.expLoading || $scope.statusLoading

      $scope.show = ->
        if attrs.experimentId then (experiment_id and $scope.status) else $scope.status

      onResize = ->
        $timeout ()->
          elem.find('.left-content').css('width', '40%')
          right_width = elem.find('.right-content').width() + 10
          elem.find('.left-content').css('width', 'calc(100% - ' + right_width + 'px)')
          elem.find('.right-content').css('opacity', '1')
        , 10

      getExperiment = (cb) ->
        return if !experiment_id
        Experiment.get(id: experiment_id).then (resp) ->          
          $scope.expLoading = false
          cb resp.experiment if cb

      $scope.is_holding = false
      $scope.enterState = false
      $scope.done = false
      $scope.state = 'idle' #by default

      checkStatus = () ->
        getExperiment (exp) ->
          $scope.experiment = exp
          onResize()
          # if !$scope.experiment.completed_at
          #   $timeout checkStatus, 1000

      #checkStatus()


      $scope.$on 'status:data:updated', (e, data, oldData) ->
        return if !data
        return if !data.experiment_controller
        counter++
        $scope.statusData = data
        $scope.state = data.experiment_controller.machine.state
        $scope.thermal_state = data.experiment_controller.machine.thermal_state
        $scope.oldState = oldData?.experiment_controller?.machine?.state || 'NONE'
        $scope.isCurrentExp = parseInt(data.experiment_controller.experiment?.id) is parseInt(experiment_id)
        if $scope.isCurrentExp is true
          if !$scope.isStarted and data.experiment_controller.machine.state != 'idle'
            $scope.isStarted = true
          else if $scope.isStarted and data.experiment_controller.machine.state == 'idle'
            $scope.isStarted = false
            
          $scope.enterState = $scope.isCurrentExp
        #console.log $scope.enterState

        if ((($scope.oldState isnt $scope.state or !$scope.experiment))) and experiment_id
          getExperiment (exp) ->
            $scope.experiment = exp
            $scope.status = data
            $scope.is_holding = TestInProgressHelper.set_holding(data, exp)
            if $scope.state is 'idle' && $scope.experiment.completed_at
              $scope.done = true
            else if $scope.state is 'idle' && !$scope.experiment.completed_at
              checkStatus()
        else
          $scope.status = data
          $scope.is_holding = TestInProgressHelper.set_holding(data, $scope.experiment)

        $scope.timeRemaining = TestInProgressHelper.timeRemaining(data)
        $scope.timePercentage = TestInProgressHelper.timePercentage(data)
        if $scope.statusLoading > 0 
          $scope.statusLoading--

        #in progress
        if $scope.state isnt 'idle' and $scope.state isnt 'complete' and $scope.isCurrentExp
          $scope.backgroundStyle =
            background: "-webkit-linear-gradient(left,  #64b027 0%,#c6e35f #{$scope.timePercentage || 0}%,#5d8329 #{$scope.timePercentage || 0}%,#5d8329 100%)"
        else if $scope.state is 'complete' and $scope.isCurrentExp
          $scope.backgroundStyle =
            background: "-webkit-linear-gradient(left,  #64b027 0%,#c6e35f 100%,#5d8329 100%,#5d8329 100%)"
        else if $scope.state is 'idle' and !$scope.dataAnalysis and $scope.enterState
          $scope.backgroundStyle =
            background: "-webkit-linear-gradient(left,  #64b027 0%,#c6e35f 100%,#5d8329 100%,#5d8329 100%)"
        else
          $scope.backgroundStyle = {}

        onResize()

      $scope.getDuration = ->
        return 0 if !$scope?.experiment?.completed_at
        Experiment.getExperimentDuration($scope.experiment)

      $scope.startExperiment = ->
        $scope.isStarted = true
        Experiment.startExperiment(experiment_id).then ->
          $scope.experiment.started_at = true
          $scope.expLoading = true
          $scope.statusLoading = INIT_LOADING
          getExperiment (exp) ->
            $scope.experiment = exp
            $rootScope.$broadcast 'experiment:started', experiment_id
            if $state.is('edit-protocol')
              max_cycle = Experiment.getMaxExperimentCycle($scope.experiment)
              $state.go('run-experiment', {'id': experiment_id, 'chart': 'amplification', 'max_cycle': max_cycle})
        .catch (resp) ->
          console.log('error')
          alerts.showMessage(resp.data.status.error, $scope);

      $scope.startConfirm = ->
        $scope.start_confirm_show = true
        controller.start_confirm_show = $scope.start_confirm_show


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

      $scope.$on 'complete', ->
        getExperiment (exp) ->
          $scope.dataAnalysis = true
          $scope.experiment = exp

      $scope.$watch 'experimentId', (id) ->
        return if !id
        experiment_id = id
        getExperiment (exp) ->
          $scope.experiment = exp

      $scope.$on 'window:resize', ->
        onResize()

]
