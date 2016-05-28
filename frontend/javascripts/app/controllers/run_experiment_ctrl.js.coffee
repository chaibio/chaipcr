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
window.ChaiBioTech.ngApp.controller 'RunExperimentCtrl', [
  '$scope'
  '$stateParams'
  '$state'
  'Experiment'
  '$uibModal'
  ($scope, $stateParams, $state, Experiment, $uibModal) ->
    @chart = $stateParams.chart
    # $scope.chart = $stateParams.chart
    $scope.hover= ""
    $scope.noofCharts = 2
    $scope.meltCurveChart = false; #if the experiment has a melt curve stage

    $scope.getMeltCurve = () ->
      stages = $scope.experiment.protocol.stages
      return stages.some((val) => val.stage.name is "Melt Curve Stage")

    @changeChart = (chart) ->
      $state.go 'run-experiment', {id: $stateParams.id, chart: chart}, notify: false
      @chart = chart
      $scope.chart = chart
      if $scope.uiModal
        $scope.uiModal.close()

    @changeChartTypeModal = ->

      templateUrl = 'app/views/experiment/choose-chart.html'
      windowClass = 'modal-4-charts'

      if $scope.noofCharts == 3
        templateUrl = 'app/views/experiment/choose-chart-3.html'
        windowClass = 'modal-3-row'
      else if $scope.noofCharts == 2
        windowClass = 'modal-2-row'
        templateUrl = 'app/views/experiment/choose-chart-3.html'

      $scope.uiModal = $uibModal.open({
        templateUrl: templateUrl,
        scope: $scope,
        windowClass: windowClass
      });


    Experiment.get(id: $stateParams.id).then (data) ->
      Experiment.setCurrentExperiment data.experiment
      $scope.experiment = data.experiment
      if $scope.getMeltCurve()
        $scope.meltCurveChart = true;
        $scope.noofCharts = $scope.noofCharts + 1;


]
