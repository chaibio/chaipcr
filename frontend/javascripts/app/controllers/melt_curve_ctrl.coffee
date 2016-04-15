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
    $scope.data = MeltCurveService.defaultData()
    has_data = false
    PARSED_DATA = null
    OPTIMIZED_DATA = null

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

    # updateZoomRange = (min, max) ->
    #   $scope.zoom_range = max - min
    #   console.log "$scope.zoom_range: #{$scope.zoom_range}"

    updateResolutionOptions = (data) ->
      calibration = 10
      zoom_unit = data['well_0'].length/calibration
      zoom_unit = Math.ceil(zoom_unit)
      $scope.resolutionOptions = []
      for i in [calibration..1] by -1
        $scope.resolutionOptions.push(zoom_unit*i)

      OPTIMIZED_DATA = MeltCurveService.optimizeForEachResolution(PARSED_DATA, $scope.resolutionOptions)
      # console.log OPTIMIZED_DATA

    changeResolution = ->
      resolution = $scope.resolutionOptions[$scope.mc_zoom]
      $scope.data = OPTIMIZED_DATA[$scope.mc_zoom]
      # data = MeltCurveService.optimizeForResolution(PARSED_DATA, resolution)
      # console.log data
      # $scope.data = data

    $scope.$watch 'RunExperimentCtrl.chart', (chart) ->
      if chart is 'melt-curve' and !has_data
        getExperiment (exp) ->
          getMeltCurveData (data) ->
            console.log 'melt curve data loaded'
            console.log data
            temp_range = MeltCurveService.getTempRange(data.melt_curve_data)
            updateConfigs
              axes:
                x:
                  min: temp_range.min
                  max: temp_range.max
                  ticks: MeltCurveService.XTicks(temp_range.min, temp_range.max)

            # updateZoomRange(temp_range.min, temp_range.max)

            MeltCurveService.parseData(data.melt_curve_data).then (data) ->
              has_data = true
              $scope.loading = false
              # $scope.data = data
              PARSED_DATA = angular.copy(data)
              updateResolutionOptions(data)
              changeResolution()

              # $timeout ->
              #   $scope.$broadcast '$reload:n3:charts'
              # , 1500

    $scope.$watch ->
      $scope.RunExperimentCtrl.chart
    , (chart) ->
      if chart is 'temperature-logs'
        $timeout ->
          $scope.$broadcast '$reload:n3:charts'
        , 3000

    $scope.$watch ->
      $scope.mc_zoom
    , (val) ->
      return if !PARSED_DATA
      changeResolution()

]