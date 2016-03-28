App.controller 'MeltCurveCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  'MeltCurveService'
  '$timeout'
  ($scope, Experiment, $stateParams, MeltCurveService, $timeout) ->

    $scope.curve_type = 'derivative'
    $scope.chartConfigDerivative = MeltCurveService.chartConfig('derivative')
    $scope.chartConfigNormalized = MeltCurveService.chartConfig('normalized')
    $scope.loading = null

    getMeltCurveData = (cb) ->
      $scope.loading = true
      $timeout ->
        Experiment.getMeltCurveData($stateParams.id)
        .then (resp) ->
          cb(resp.data) if !!cb
        .catch ->
          $scope.loading = false
          $scope.error = 'Unable to retrieve melt curve data.'
      , 1500

    getExperiment = (cb) ->
      Experiment.get(id: $stateParams.id).then (data) ->
        $scope.experiment = data.experiment
        cb(data.experiment) if !!cb

    updateConfigs = (opts) ->
      $scope.chartConfigDerivative = _.defaultsDeep angular.copy(opts), $scope.chartConfigDerivative
      $scope.chartConfigNormalized = _.defaultsDeep angular.copy(opts), $scope.chartConfigNormalized

    $scope.$watch 'RunExperimentCtrl.chart', (chart) ->
      if chart is 'melt-curve' and !$scope.data
        console.log 'here!1'
        getExperiment (exp) ->
          getMeltCurveData (data) ->
            temp_range = MeltCurveService.getTempRange(data.melt_curve_data)
            updateConfigs
              axes:
                x:
                  min: temp_range.min
                  max: temp_range.max
                  ticks: MeltCurveService.XTicks(temp_range.min, temp_range.max)

            MeltCurveService.parseData data.melt_curve_data, (data) ->
              $scope.loading = false
              $scope.data = data

              $timeout ->
                $scope.$broadcast '$reload:n3:charts'
              , 1500

    $scope.$watch ->
      $scope.RunExperimentCtrl.chart
    , (chart) ->
      if chart is 'temperature-logs'
        $timeout ->
          $scope.$broadcast '$reload:n3:charts'
        , 3000

]