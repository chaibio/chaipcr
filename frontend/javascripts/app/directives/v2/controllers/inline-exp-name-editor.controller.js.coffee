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
window.ChaiBioTech.ngApp.controller 'InlineExpNameEditorCtrl', [
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
    $scope.ori_experiment_name = ''

    $scope.adjustTextWidth = () ->
      $timeout (() ->
        field_width = Math.max(document.getElementById('inline_exp_name_plat').offsetWidth + 20, 150)
        field_width = Math.min(document.getElementsByClassName('inline-exp-name')[0].offsetWidth - 110, field_width)
        angular.element(document.getElementById('inline_exp_name_field')).css('width', (field_width) + 'px')
      ), 10
      return

    $scope.focusExpName = ->
      field_width = Math.max(document.getElementById('inline_exp_name_plat').offsetWidth + 20, 150)
      field_width = Math.min(document.getElementsByClassName('inline-exp-name')[0].offsetWidth - 110, field_width)
      angular.element(document.getElementById('inline_exp_name_field')).css('width', (field_width) + 'px')
      
      $scope.ori_experiment_name = $scope.experiment.name
      $scope.removeMessages()
      $scope.editExpNameMode = true
      focus('editExpNameMode')
      document.getElementById('inline_exp_name_field').select()

    $scope.cancelExpName = ->      
      $scope.editModeOff()
      $scope.experiment.name = $scope.ori_experiment_name

    $scope.removeMessages = ->
      $scope.successName = null
      $scope.errors = null

    $scope.editModeOff = ->
      angular.element(document.getElementById('inline_exp_name_plat')).css('width', 'auto')
      $scope.editExpNameMode = false

    $scope.saveExperiment = (exp)->
      return if $scope.expForm.$invalid
      promise = Experiment.update({id: $scope.experiment.id}, experiment: $scope.experiment).$promise

      promise.then ->
        $scope.ori_experiment_name = $scope.experiment.name
        expName.updateName($scope.experiment.name)
        $timeout (() ->
          $scope.successName = null
          ), 2000

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig
        $scope.experiment.name = $scope.ori_experiment_name

      promise.finally ->
        if !$scope.errors
          $scope.editModeOff()

    $scope.$on 'window:resize', ->
      $scope.adjustTextWidth()

]
