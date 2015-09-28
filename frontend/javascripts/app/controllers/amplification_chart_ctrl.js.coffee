window.ChaiBioTech.ngApp.controller 'AmplificationChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  'AmplificationChartHelper'
  ($scope, $stateParams, Experiment, helper) ->

    COLORS = [
      '#FFE980'
      '#FFD380'
      '#FFAD80'
      '#FF6666'
      '#FF71BA'
      '#C890F4'
      '#3879FF'
      '#75E0FF'
      '#FFD200'
      '#FFA800'
      '#FF5A00'
      '#E50000'
      '#F0007C'
      '#8F1CE8'
      '#003CB7'
      '#00BEF5'
    ]

    $scope.chartConfig = helper.chartConfig

    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      $scope.experiment = data.experiment

    Experiment.getFluorescenceData($stateParams.id)
    .success (data) ->
      $scope.chartConfig.axes.x.max = data.total_cycles
      $scope.chartConfig.axes.y.max = helper.getGreatestCalibration data.fluorescence_data
      $scope.data = helper.neutralizeData data.fluorescence_data

    $scope.$watch 'wellButtons', (buttons) ->
      buttons = buttons || []
      $scope.chartConfig.series = []

      for i in [0..15] by 1
        if buttons["well_#{i}"]
          $scope.chartConfig.series.push
            y: "well_#{i}"
            color: COLORS[i]
            thickness: '3px'
]
