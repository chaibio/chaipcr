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
  'HomePageDelete',
  ($scope, Experiment, $window, $uibModal, $timeout, $state, User, Status, HomePageDelete) ->

    angular.element('body').addClass 'modal-form'
    $scope.$on '$destroy', ->
      angular.element('body').removeClass 'modal-form'

    $scope.experiments = null
    $scope.deleteMode = false

    User.getCurrent().then (resp) ->
      $scope.user = resp.data.user

    @fetchExperiments = ->
      Experiment.query (experiments) ->
        $scope.experiments = experiments

    @fetchExperiments()

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

    @deleteExperiment = (data) =>
      experiment = data.experiment
      exp = new Experiment id: experiment.id
      exp.$remove =>
        $scope.experiments = _.reject $scope.experiments, (exp) ->
          exp.experiment.id is experiment.id
      , (resp) ->
        $window.alert resp.data.experiment?.errors?.base || 'Unable to delete experiment.'
        data.del = false

    @expName = (exp_name, truncate_length) ->
      NAME_LENGTH = parseInt(truncate_length)
      return if !exp_name
      return exp_name if exp_name.length <= NAME_LENGTH
      return exp_name.substring(0, NAME_LENGTH-2)+'...'

    @openExperiment = (exp) ->
      if not $scope.deleteMode
        state = Status.getData();
        if state.experiment_controller.machine.state == 'running' and exp.id == state.experiment_controller.expriment.id
          $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}

        if exp.started_at isnt null
          $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}
        else
          $state.go 'edit-protocol', {id: exp.id}


    return

]
