window.ChaiBioTech.ngApp.controller 'AmplificationChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  'AmplificationChartHelper'
  ($scope, $stateParams, Experiment, helper) ->

    $scope.chartConfig = helper.chartConfig()

    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      $scope.experiment = data.experiment

    Experiment.getFluorescenceData($stateParams.id)
    .success (data) ->
      $scope.chartConfig.axes.x.max = data.total_cycles
      $scope.data = helper.neutralizeData data.fluorescence_data

    $scope.$watch 'wellButtons', (buttons) ->
      buttons = buttons || []
      $scope.chartConfig.series = []

      for i in [0..15] by 1
        if buttons["well_#{i}"]?.selected
          $scope.chartConfig.series.push
            y: "well_#{i}"
            color: buttons["well_#{i}"].color
            thickness: '3px'
]
