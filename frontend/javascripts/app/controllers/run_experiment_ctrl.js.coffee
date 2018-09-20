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
  'ChoosenChartService'
  ($scope, $stateParams, $state, Experiment, ChoosenChartService) ->
    $scope.chart = $stateParams.chart

    changeChart = (chart) ->
      $state.go 'run-experiment', {id: $stateParams.id, chart: chart}, notify: false
      $scope.chart = chart

    hasChart = (chart) ->
      switch chart
        when 'amplification'
          return Experiment.hasAmplificationCurve($scope.experiment)
        when 'standard-curve'
          return Experiment.hasStandardCurve($scope.experiment)
        when 'melt-curve'
          return Experiment.hasMeltCurve($scope.experiment)
        when 'temperature-logs'
          return true;
        else
          return false;

    ChoosenChartService.setCallback(changeChart)


    Experiment.get(id: $stateParams.id).then (data) ->
      $scope.experiment = data.experiment

      if !hasChart($scope.chart)
        chart = null
        chart = 'amplification' if Experiment.hasAmplificationCurve($scope.experiment)
        chart = 'standard-curve' if Experiment.hasStandardCurve($scope.experiment)
        chart = 'melt-curve' if Experiment.hasMeltCurve($scope.experiment) and !chart
        chart = 'temperature-logs' if !chart
        changeChart(chart)

]
