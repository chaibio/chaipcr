window.ChaiBioTech.ngApp.controller 'TemperatureLogCtrl', [
  '$scope'
  'Experiment'
  'TemperatureLogService'
  'SecondsDisplay'
  'Status'
  '$interval'
  '$stateParams'
  '$rootScope'
  '$timeout'
  ($scope, Experiment, TemperatureLogService, SecondsDisplay, Status, $interval, $stateParams, $rootScope, $timeout) ->

    $scope.updateInterval = null
    greatest_elapsed_time = 0
    orig_greatest_elapsed_time = -1
    TEMPERATURE_LOGS_CACHE = []
    $scope.options = TemperatureLogService.chartConfig
    $scope.showChart = true
    $scope.ampli_zoom = {
      value: 0
      width: 0.2
    }
    $scope.dataPointAt = {
      elapsed_time: 0
      heat_block_zone_temp: 0
      lid_temp: 0
    }

    $scope.data = dataset: []

    fetchTemperatureLogs = ->
      console.log "chart: #{$scope.$parent.chart}"
      return if $scope.$parent.chart isnt 'temperature-logs'
      Experiment.getTemperatureData($stateParams.id, starttime: Math.floor(orig_greatest_elapsed_time+1)*1000)
      .then (data) ->
        return if !data
        return if data.length is 0
        $scope.hasData = true
        orig_greatest_elapsed_time = TemperatureLogService.getGreatestElapsedTime(data)/1000
        greatest_elapsed_time = Math.ceil(orig_greatest_elapsed_time)
        greatest_elapsed_time = if greatest_elapsed_time < 5*60 then 60*5 else greatest_elapsed_time
        # $scope.data = $scope.data || {dataset: []}
        new_data = TemperatureLogService.parseData(data)
        $scope.options.axes.y.max = if new_data.max_y > $scope.options.axes.y.max then new_data.max_y else $scope.options.axes.y.max
        TEMPERATURE_LOGS_CACHE = TEMPERATURE_LOGS_CACHE.concat(new_data.dataset)
        TEMPERATURE_LOGS_CACHE = TemperatureLogService.reorderData(TEMPERATURE_LOGS_CACHE)
        $scope.data = dataset: TEMPERATURE_LOGS_CACHE
        console.log $scope.data
        # TEMPERATURE_LOGS_CACHE = TemperatureLogService.reorderData(TEMPERATURE_LOGS_CACHE)
        # console.log TEMPERATURE_LOGS_CACHE

    autoUpdateTemperatureLogs = ->
      if !$scope.updateInterval
        fetchTemperatureLogs()
        $scope.updateInterval = $interval fetchTemperatureLogs, 10000

    stopInterval = =>
      $interval.cancel $scope.updateInterval if $scope.updateInterval
      $scope.updateInterval = null

    $scope.$on 'status:data:updated', (e, val) ->
      if val
        # $scope.scrollState = $scope.scrollState || 'FULL'
        isCurrentExperiment = parseInt(val.experiment_controller?.experiment?.id) is parseInt($stateParams.id)
        if isCurrentExperiment and (val.experiment_controller?.machine.state is 'lid_heating' || val.experiment_controller?.machine.state is 'running')
          autoUpdateTemperatureLogs()
        else
          stopInterval()

    $scope.mouseMove = (data_point) ->
      $scope.dataPointAt = data_point

    $scope.tempOnZoom = (transform, w, h, scale_extent) ->
      # console.log transform, w, h, scale_extent
      $scope.scrollState = {
        value: Math.abs(transform.x/(w*transform.k - w))
        width: w/(w*transform.k)
      }
      $scope.zoomState = (transform.k - 1)/ (scale_extent)

    $scope.$watch ->
      $scope.$parent.chart
    , (chart) ->
      if chart is 'temperature-logs'
        if !$scope.hasData
          fetchTemperatureLogs()

        $timeout ->
          $scope.showChart = true
        , 1000
      else
        $scope.showChart = false

]