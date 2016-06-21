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
window.ChaiBioTech.ngApp.controller('ExperimentMenuOverlayCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  '$state'
  'AmplificationChartHelper'
  'Status',
  '$timeout'
  '$rootScope'
  ($scope, $stateParams, Experiment, $state, AmplificationChartHelper, Status, $timeout, $rootScope) ->
    $scope.params = $stateParams
    $scope.lidOpen = false
    $scope.showProperties = false
    $scope.status = null
    $scope.exp = null

    $scope.deleteExperiment = ->
      exp = new Experiment id: $stateParams.id
      exp.$delete id: $stateParams.id, ->
        $state.go 'home'

    $scope.$watch (()->
      $scope.showProperties), (val) ->
        $scope.showHide = if val then 'HIDE' else 'SHOW'

    $scope.$on 'cycle:number:updated', (e, num) ->
      $scope.maxCycle = num

    $scope.getExperiment = ->
      Experiment.get(id: $stateParams.id).then (data) ->
        $scope.exp = data.experiment
        if !data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'NOT_STARTED'
          $scope.runStatus = 'Not run yet.'
        if data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'RUNNING'
          $scope.runStatus = 'Currently running.'
        if data.experiment.started_at and data.experiment.completed_at
          $scope.status = 'COMPLETED'
          $scope.runStatus = 'Run on:'

        $scope.maxCycle = AmplificationChartHelper.getMaxExperimentCycle data.experiment

    $scope.getExperiment()

    $rootScope.$on 'sidemenu:toggle', ->
      if $scope.showProperties and angular.element('.sidemenu').width() > 100
        $scope.showProperties = false

    $scope.$on 'status:data:updated', (e, data, oldData) ->
      $scope.lidOpen = if data?.optics?.lid_open == "true" then true else false
      state = data?.experiment_controller?.machine?.state
      oldState = oldData?.experiment_controller?.machine?.state
      $scope.getExperiment() if state isnt oldState

])
