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
window.ChaiBioTech.ngApp.controller 'EditExperimentPropertiesCtrl', [
  '$scope'
  'focus'
  'Experiment'
  '$stateParams'
  'expName'
  'Protocol'
  'Status'
  '$timeout'
  ($scope, focus, Experiment, $stateParams, expName, Protocol, Status, $timeout) ->

    if !Experiment.getCurrentExperiment()
      Experiment.get {id: $stateParams.id}, (data) ->
        Experiment.setCurrentExperiment data.experiment
        $scope.experiment = data.experiment
        $scope.experimentOrig = angular.copy data.experiment
    else
      $scope.experiment = Experiment.getCurrentExperiment()
      $scope.experimentOrig = angular.copy $scope.experiment

    $scope.editExpNameMode = false

    getData = ->
      Experiment.get(id: $stateParams.id).then (data) ->
        $scope.experiment = data.experiment
        $scope.experimentOrig = angular.copy data.experiment
        if !data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'NOT_STARTED'
          $scope.runStatus = 'Not run yet.'
        if data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'RUNNING'
          $scope.runStatus = 'Currently running.'
        if data.experiment.started_at and data.experiment.completed_at
          $scope.status = 'COMPLETED'
          $scope.runStatus = 'Run on:'

    getData()

    $scope.$on 'status:data:updated', (e, data) ->
      if parseInt(data?.experiment_controller?.experiment?.id) is parseInt($stateParams.id) and $scope.experiment
        $scope.experiment.started_at = data.experiment_controller.experiment.started_at
        $scope.experiment.completed_at = data.experiment_controller.experiment.completed_at

    $scope.removeMessages = ->
      $scope.successLid = $scope.successName = null
      $scope.errors = null


    $scope.typeSelected = (type) ->
      $scope.selectedType = type

    $scope.focusExpName = ->

      #if $scope.status == "NOT_STARTED"
      $scope.removeMessages()
      $scope.editExpNameMode = true
      focus('editExpNameMode')

    $scope.focusLidTemp = ->
      if $scope.status == "NOT_STARTED"
        $scope.removeMessages()
        if $scope.experiment?.started_at
          $scope.errors = "Experiment has been run."
          return

        $scope.editLidTempMode = true
        focus('editLidTempMode')

    $scope.editModeOff = ->
      $scope.editExpNameMode = false
      $scope.editLidTempMode = false

    $scope.saveExperiment = (exp)->
      return if $scope.expForm.$invalid
      promise = Experiment.update({id: $scope.experiment.id}, experiment: $scope.experiment).$promise

      promise.then ->
        $scope.successName = "Experiment name updated."
        expName.updateName($scope.experiment.name)
        $timeout (() ->
          $scope.successName = null
          ), 2000

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig

      promise.finally ->
        $scope.editModeOff()

    $scope.updateProtocol = (data, expForm) ->
      if expForm.lidTemp.$invalid
        $scope.experiment.protocol.lid_temperature = $scope.experimentOrig.protocol.lid_temperature
        return

      if data.lid_temperature > 120
        $scope.experiment.protocol.lid_temperature = 120
        data.lid_temperature = 120

      promise = Protocol.update data

      promise.success ->
        $scope.successLid = "Lid temperature updated."
        $timeout (() ->
          $scope.successLid = null
          ), 2000

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig

      promise.finally ->
        $scope.editModeOff()

]
