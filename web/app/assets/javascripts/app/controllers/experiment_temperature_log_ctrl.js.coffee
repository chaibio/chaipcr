window.ChaiBioTech.ngApp

.controller 'ExperimentTemperatureLogCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  'ChartData'
  'SecondsDisplay'
  '$state'
  ($scope, Experiment, $stateParams, ChartData, SecondsDisplay, $state) ->

    @temperatureLogs = []
    chunkLength = 12

    $scope.options =
      pointDot: false
      datasetFill: false
      scaleShowHorizontalLines: false
      scaleShowVerticalLines: false

    $scope.series = ['Heat block zone 1', 'Heat block zone 2', 'Lid']

    @init = ->
      Experiment
      .getTemperatureData($stateParams.expId)
      .success (data) =>
        @temperatureLogs = data
        @setStarttimeEndtimeChoices data
        @updateChartData $scope.starttime, $scope.endtime

    @navigate = (starttime, endtime) ->
      $state.go 'expTemperatureLog',
        starttime: starttime
        endtime: endtime
      ,
        notify: false

    @validateTimeRange = (starttime, endtime) ->
      if starttime > endtime
        endIndex = _.indexOf $scope.endtimeChoices, endtime
        starttime = $scope.starttimeChoices[endIndex]

      starttime: starttime
      endtime: endtime

    @updateChartData = (starttime, endtime) =>

      validated = @validateTimeRange starttime, endtime
      starttime = $scope.starttime = validated.starttime
      endtime = $scope.endtime = validated.endtime

      @navigate starttime, endtime # udpate url

      data = _.select @temperatureLogs, (n) ->
        n.temperature_log.elapsed_time >= starttime and if endtime then n.temperature_log.elapsed_time <= endtime else true

      data = ChartData.temperatureLogs.toAngularCharts(data)

      if data.elapsed_time.length > 50
        $scope.labels = _.map data.elapsed_time, -> ''
      else
        $scope.labels = data.elapsed_time

      $scope.data = [
        data.heat_block_zone_1_temp
        data.heat_block_zone_2_temp
        data.lid_temp
      ]

    @optionText = SecondsDisplay.display1

    @setStarttimeEndtimeChoices = (data) ->
      $scope.starttimeChoices = []
      $scope.endtimeChoices = []

      chunks = _.chunk data, chunkLength

      for chunk in chunks
        endtime = chunk[chunk.length - 1].temperature_log.elapsed_time
        starttime = chunk[0].temperature_log.elapsed_time

        $scope.starttimeChoices.push starttime
        $scope.endtimeChoices.push endtime

      $scope.starttime = parseInt $stateParams.starttime ||  $scope.starttimeChoices[0]
      $scope.endtime = parseInt $stateParams.endtime ||  $scope.endtimeChoices[0]

    return

]