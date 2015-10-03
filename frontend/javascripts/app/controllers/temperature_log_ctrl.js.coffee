window.ChaiBioTech.ngApp.controller 'TemperatureLogCtrl', [
  '$scope'
  '$stateParams'
  'Status'
  'Experiment'
  'SecondsDisplay'
  '$interval'
  '$rootScope'
  'expName'
  'TemperatureLogChartHelpers'
  ($scope, $stateParams, Status, Experiment, SecondsDisplay, $interval, $rootScope, expName, helper) ->

    hasStatusData = false
    hasExperiment = false
    hasInit = false
    dragScroll = angular.element('.chart-drag-scroll')
    $scope.options = helper.chartConfig
    $scope.data = []
    $scope.data.push
      elapsed_time: 0
      lid_temp: 0
      heat_block_zone_temp: 0

    $scope.$on 'expName:Updated', ->
      $scope.experiment?.name = expName.name

    Status.startSync()
    $scope.$on '$destroy', ->
      Status.stopSync()
      $scope.stopInterval()

    getExperiment = ->
      Experiment.get id: $stateParams.id, (data) ->
        $scope.experiment = data.experiment
        hasExperiment = true
        $scope.init()

    getExperiment()

    $scope.$watch ->
      Status.getData()
    , (val) ->
      if val
        hasStatusData = true
        $scope.isCurrentExperiment = parseInt(val.experimentController?.expriment?.id) is parseInt($stateParams.id)
        if $scope.isCurrentExperiment and ($scope.scrollState >= 1 || $scope.scrollState is 'FULL') and (val.experimentController?.machine.state is 'LidHeating' || val.experimentController?.machine.state is 'Running')
          $scope.autoUpdateTemperatureLogs()
        else
          $scope.stopInterval()

        $scope.init()

    $scope.init = ->

      return if !hasStatusData or !hasExperiment or hasInit
      hasInit = true

      $scope.isCurrentExperiment = false

      $scope.temperatureLogs = []
      $scope.temperatureLogsCache = []
      $scope.calibration = 800
      $scope.updateInterval = null


      $scope.resolutionOptions = []
      $scope.resolutionOptionsIndex = 0

      Experiment
      .getTemperatureData($stateParams.id, resolution: 1000)
      .success (data) =>
        hasTemperatureLogs = true
        if data.length > 0
          $scope.temperatureLogsCache = angular.copy data
          $scope.temperatureLogs = angular.copy data
          $scope.greatest_elapsed_time = Math.floor data[data.length - 1].temperature_log.elapsed_time
          $scope.initResolutionOptions()
          $scope.resolutionOptionsIndex = $scope.resolutionOptions.length-1
          $scope.resolution = $scope.resolutionOptions[$scope.resolutionOptionsIndex]
          $scope.updateYScale()
          $scope.updateScrollWidth()
          $scope.resizeTemperatureLogs()
          $scope.updateResolution()
          data = helper.updateData $scope.temperatureLogsCache, $scope.temperatureLogs, $scope.resolution, $scope.scrollState
          $scope.updateChart data
        else
          # $scope.data = []
          $scope.autoUpdateTemperatureLogs()

    $scope.zoomOut = ->
      if $scope.resolutionOptions.length > 0 and $scope.resolutionOptionsIndex isnt ($scope.resolutionOptions.length - 1)
        $scope.resolutionOptionsIndex += 1

        if $scope.greatest_elapsed_time/1000 < 60*5 and $scope.resolutionOptionsIndex is $scope.resolutionOptions.length-1
          $scope.options.axes.x.max = 60*5
          $scope.options.axes.x.ticks = []
          for i in [0..5]
            $scope.options.axes.x.ticks.push i*60

      $scope.resolution = $scope.resolutionOptions[$scope.resolutionOptionsIndex]
      $scope.updateResolution()

    $scope.zoomIn = ->
      if $scope.resolutionOptionsIndex isnt 0 and $scope.resolutionOptions.length
        $scope.resolutionOptionsIndex -= 1
        $scope.resolution = $scope.resolutionOptions[$scope.resolutionOptionsIndex]
        $scope.updateResolution()
        delete $scope.options.axes.x.max
        delete $scope.options.axes.x.ticks = 8

    $scope.updateYScale = ->
      scales = _.map $scope.temperatureLogsCache, (temp_log) ->
        temp_log = temp_log.temperature_log
        greatest = Math.max.apply Math, [
          parseFloat temp_log.lid_temp
          parseFloat temp_log.heat_block_zone_1_temp
          parseFloat temp_log.heat_block_zone_2_temp
        ]
        greatest

      max_scale = Math.max.apply Math, scales
      max_scale = Math.ceil(max_scale/10)*10
      max_scale = if max_scale < 100 then 100 else max_scale
      $scope.options.axes.y.max = max_scale

    $scope.updateDragScrollWidthAttr = ->
      dragScrollWidth = dragScroll.css('width').replace 'px', ''
      w = ($scope.greatest_elapsed_time / 1000) / $scope.resolution * dragScrollWidth
      dragScroll.attr 'width', Math.round w

    $scope.updateScrollWidth = ->

      if $scope.temperatureLogsCache.length > 0
        $scope.widthPercent = $scope.resolution*1000/$scope.greatest_elapsed_time
        if $scope.widthPercent > 1
          $scope.widthPercent = 1
      else
        $scope.widthPercent = 1

      angular.element('.scrollbar').css width: "#{$scope.widthPercent*100}%"
      $rootScope.$broadcast 'scrollbar:width:changed'

    $scope.resizeTemperatureLogs = ->
      resolution = $scope.resolution
      if $scope.resolution> $scope.greatest_elapsed_time/1000 then resolution = $scope.greatest_elapsed_time/1000
      chunkSize = Math.round resolution / $scope.calibration
      temperature_logs = angular.copy $scope.temperatureLogsCache
      chunked = _.chunk temperature_logs, chunkSize
      averagedLogs = _.map chunked, (chunk) ->
        i = Math.floor(chunk.length/2)
        return chunk[i]

      averagedLogs.unshift temperature_logs[0]
      averagedLogs.push temperature_logs[temperature_logs.length-1]
      $scope.temperatureLogs = averagedLogs

    $scope.updateResolution = =>
      if $scope.temperatureLogsCache?.length > 0
        $scope.resizeTemperatureLogs()
        $scope.updateScrollWidth()
        $scope.updateDragScrollWidthAttr()
        data = helper.updateData $scope.temperatureLogsCache, $scope.temperatureLogs, $scope.resolution, $scope.scrollState
        $scope.updateChart data

    $scope.$watch 'widthPercent', ->
      if $scope.widthPercent is 1 and $scope.isCurrentExperiment
        $scope.autoUpdateTemperatureLogs()

    $scope.$watch 'scrollState', ->
      if $scope.scrollState and $scope.temperatureLogs and $scope.data and $scope.temperatureLogsCache.length > 0
        data = helper.updateData $scope.temperatureLogsCache, $scope.temperatureLogs, $scope.resolution, $scope.scrollState
        $scope.updateChart data

        if ($scope.scrollState >= 1 or $scope.scrollState is 'FULL') and $scope.isCurrentExperiment
          $scope.autoUpdateTemperatureLogs()
        else
          $scope.stopInterval()

    $scope.$on 'experiment:started', (e, expId) ->
      if parseInt(expId) is parseInt($stateParams.id)
        if $scope.temperatureLogsCache.length is 0
          $scope.scrollState = 'FULL'
        $scope.isCurrentExperiment = true
        $scope.autoUpdateTemperatureLogs()

    $scope.$watch 'dragScroll', (val) ->
      val = $scope.resolution*val/($scope.greatest_elapsed_time/1000)
      $scope.scrollState += val*-1

    $scope.updateChart = (temperature_logs) ->
      $scope.data = helper.toN3LineChart(temperature_logs)

    updateFunc = ->
      Experiment
      .getTemperatureData($stateParams.id, resolution: 1000)
      .success (data) ->

        if data.length > 0
          $scope.temperatureLogsCache = angular.copy data
          $scope.temperatureLogs = angular.copy data
          $scope.greatest_elapsed_time = Math.floor data[data.length - 1].temperature_log.elapsed_time
          $scope.initResolutionOptions()
          if !$scope.resolution or $scope.greatest_elapsed_time/1000 < 60 * 5 and $scope.scrollState is 'FULL'
            $scope.resolutionOptionsIndex = $scope.resolutionOptions.length-1
            $scope.resolution = $scope.resolutionOptions[$scope.resolutionOptionsIndex]
          if $scope.greatest_elapsed_time/1000 > 60 * 5
            delete $scope.options.axes.x.max
            delete $scope.options.axes.x.ticks = 8
          $scope.updateYScale()
          $scope.updateScrollWidth()
          $scope.resizeTemperatureLogs()
          $scope.updateResolution()
          data = helper.updateData $scope.temperatureLogsCache, $scope.temperatureLogs, $scope.resolution, $scope.scrollState
          $scope.updateChart data

    $scope.autoUpdateTemperatureLogs = =>
      if !$scope.updateInterval
        updateFunc()
        $scope.updateInterval = $interval updateFunc, 10000

    $scope.stopInterval = =>
      $interval.cancel $scope.updateInterval if $scope.updateInterval
      $scope.updateInterval = null

    $scope.initResolutionOptions = ->
      $scope.resolutionOptions = []
      options = [
        30
        60
        60 * 2
        60 * 3
        60 * 5
        60 * 10
        60 * 20
        60 * 30
        60 * 60
        60 * 60 * 24
      ]

      for opt in options
        if opt < $scope.greatest_elapsed_time/1000
          $scope.resolutionOptions.push opt

      $scope.resolutionOptions.push Math.floor $scope.greatest_elapsed_time/1000

]