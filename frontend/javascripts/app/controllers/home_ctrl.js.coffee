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


    User.getCurrent().then (resp) ->
      $scope.user = resp.data.user

    $scope.$on 'status:experiment:completed', =>
      if !$scope.enterHome
        @fetchExperiments()

    # $scope.$on '.home-page-exp-tile', =>
    #   alert($(".home-page-exp-tile").width());

    # getWidth = ->
    #   if($(".home-page-exp-tile").width())
    #     alert($(".home-page-exp-tile").width())
    #     width = $(".home-page-exp-tile").width()
    #     $(".home-page-del").css({
    #       'left': width - 72+'px',
    #       'transition': 'left .3s'
    #     })

    #   else
    #     $timeout ->
    #       getWidth()
    #     , 2000

    #getWidth()

    @fetchExperiments = ->
      Experiment.query (experiments) ->
        $scope.experiments = experiments

    if $scope.enterHome
      @fetchExperiments()
      $timeout ->
        $scope.enterHome = false
      , 1000

    @newTestKit = ->
      modalInstance = $uibModal.open
        templateUrl: 'app/views/experiment/create-testkit-experiment.html'
        controller: 'CreateTestKitCtrl'
        openedClass: 'modal-new-testkit'
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

    # @expName = (exp_name, truncate_length) ->
    #   NAME_LENGTH = parseInt(truncate_length)
    #   return if !exp_name
    #   return exp_name if exp_name.length <= NAME_LENGTH
    #   return exp_name.substring(0, NAME_LENGTH-2)+'...'

    $scope.machine_state = 'idle' #by default
    $scope.current_experiment_id = 0
    $scope.$on 'status:data:updated', (e, data, oldData) ->
      return if !data
      return if !data.experiment_controller
      $scope.machine_state = data.experiment_controller.machine.state
      $scope.current_experiment_id = parseInt(data.experiment_controller.experiment?.id)

    @openExperiment = (exp) ->
      if not $scope.deleteMode
        state = Status.getData();
        if state.experiment_controller.machine.state == 'running' and exp.id == state.experiment_controller.experiment.id
          if exp.type isnt 'test_kit'
            $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}
          else
            $state.go 'pika_test.exp-running', id: exp.id

        else
          if exp.started_at
            $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}
          else
            $state.go 'edit-protocol', {id: exp.id}
          if exp.type isnt 'test_kit'
            if exp.started_at
              $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}
            else
              $state.go 'edit-protocol', {id: exp.id}
          else
            if not exp.started_at
              $state.go('pika_test.setWellsA', id: exp.id)
            else if exp.started_at isnt null && exp.completed_at isnt null
              $state.go('pika_test.results', id: exp.id)
            else
              $state.go 'pika_test.exp-running', id: exp.id


    return

]
