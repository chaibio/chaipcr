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

.controller 'HomeCtrl', [
  '$scope'
  'Experiment'
  '$window'
  '$uibModal'
  '$timeout'
  '$state'
  'User'
  'Status'
  ($scope, Experiment, $window, $uibModal, $timeout, $state, User, Status) ->

    angular.element('body').addClass 'modal-form'
    $scope.$on '$destroy', ->
      angular.element('body').removeClass 'modal-form'

    $scope.experiments = null
    $scope.deleteMode = false
    $scope.enterHome = true
    $scope.state = ''

    User.getCurrent().then (resp) ->
      $scope.user = resp.data.user

    $scope.$on 'status:experiment:completed', =>
      if !$scope.enterHome
        @fetchExperiments()

    @fetchExperiments = ->
      Experiment.query (experiments) ->
        $scope.experiments = experiments
        $timeout ->
          $('a.experiment-link').unbind 'click'
          $('a.experiment-link').on 'click', (e)->
            e.preventDefault()
        , 500

    if $scope.enterHome
      @fetchExperiments()
      $timeout ->
        $scope.enterHome = false
      , 1000

    @newTestKit = ->
      modalInstance = $uibModal.open
        templateUrl: 'app/views/experiment/v2/create-testkit-modal.html'
        controller: 'CreateTestKitModalCtrl'
        openedClass: 'new-testkit-modal'
        backdrop: false

    @newExperiment = ->
      modalInstance = $uibModal.open
        templateUrl: 'app/views/experiment/create-experiment-name-modal.html'
        controller: 'CreateExperimentModalCtrl'
        backdrop: false

      modalInstance.result.then (exp) ->
        $state.go 'edit-protocol', id: exp.id

    @confirmDelete = (exp) ->
      if $scope.deleteMode
        exp.del = true

    @deleteExperiment = (data) ->
      experiment = data.experiment
      Experiment.delete(experiment.id)
      .then ->
        $scope.experiments = _.reject $scope.experiments, (exp) ->
          exp.experiment.id is experiment.id
      .catch (resp) ->
        $window.alert resp.data.experiment?.errors?.base || 'Unable to delete experiment.'
        data.del = false

    $scope.machine_state = 'idle' #by default
    $scope.current_experiment_id = 0
    $scope.$on 'status:data:updated', (e, data, oldData) ->
      return if !data
      return if !data.experiment_controller
      $scope.machine_state = data.experiment_controller.machine.state
      $scope.current_experiment_id = parseInt(data.experiment_controller.experiment?.id)

    @openExperiment = (exp) ->
      if not $scope.deleteMode
        $scope.state = Status.getData()
        if $scope.state.experiment_controller.machine.state == 'running' and exp.id == $scope.state.experiment_controller.experiment.id
          if exp.type isnt 'test_kit'
            $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}
          else
            $state.go 'pika_test.experiment-running', id: exp.id

        else
          if exp.type isnt 'test_kit'
            if exp.started_at
              $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}
            else
              $state.go 'edit-protocol', {id: exp.id}
          else
            if not exp.started_at
              $state.go('pika_test.set-wells', id: exp.id)
            else if exp.started_at isnt null && exp.completed_at isnt null
              $state.go('pika_test.experiment-result', id: exp.id)
            else
              $state.go 'pika_test.experiment-running', id: exp.id
    return
]
