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
App.controller 'MeltCurveChartCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  'MeltCurveService'
  '$timeout'
  '$interval'
  ($scope, Experiment, $stateParams, MeltCurveService, $timeout, $interval) ->

    $scope.curve_type = 'derivative'
    $scope.color_by = 'well'
    $scope.chartConfigDerivative = MeltCurveService.chartConfig('derivative')
    $scope.chartConfigNormalized = MeltCurveService.chartConfig('normalized')
    $scope.data = MeltCurveService.defaultData()
    has_data = false
    PARSED_DATA = null
    OPTIMIZED_DATA = null
    $scope.retrying = false
    $scope.retry = 0
    $scope.fetching = false


    retry = ->
      $scope.retrying = true
      $scope.retry = 10
      retryInterval = $interval ->
        $scope.retry = $scope.retry - 1
        if $scope.retry is 0
          $interval.cancel(retryInterval)
          $scope.retrying = false
          getMeltCurveData()
      , 1000

    getMeltCurveData = (cb) ->
      gofetch = true
      gofetch = false if $scope.fetching
      gofetch = false if $scope.RunExperimentCtrl.chart isnt 'melt-curve'
      gofetch = false if $scope.retrying

      if gofetch
        $scope.fetching = true
        $timeout ->
          Experiment.getMeltCurveData($stateParams.id)
          .then (resp) ->
            cb(resp.data) if !!cb
            console.log 'melt curve data loaded!!'
          .catch (resp) ->
            $scope.fetching = false
            $scope.error = if resp.data?.errors then resp.data.errors else 'Unable to retrieve melt curve data due to some error.'
            retry()
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
      zoom_calibration = 10
      zoom_unit = Math.ceil(data['well_0'].length/zoom_calibration)
      $scope.resolutionOptions = []
      for i in [zoom_calibration..1] by -1
        $scope.resolutionOptions.push(zoom_unit*i)

      OPTIMIZED_DATA = MeltCurveService.optimizeForEachResolution(PARSED_DATA, $scope.resolutionOptions)

    updateButtonTms = (data) ->
      for well_data, well_i in data.melt_curve_data by 1
        $scope.wellButtons["well_#{well_i}"].ct = [MeltCurveService.averagedTm(well_data.tm)]


    updateSeries = (buttons) ->
      buttons = buttons || $scope.wellButtons || {}
      channel_count = if $scope.is_dual_channel then 2 else 1
      chartConfig = if $scope.curve_type is 'derivative' then 'chartConfigDerivative' else 'chartConfigNormalized'

      $scope[chartConfig].series = []

      for i in [0..15] by 1
        if buttons["well_#{i}"]?.selected
          $scope[chartConfig].series.push
            key: $scope.curve_type
            axis: 'y'
            dataset: "well_#{i}"
            color: buttons["well_#{i}"].color
            label: "well_#{i+1}: "
            interpolation: {mode: 'cardinal', tension: 0.7}

    changeResolution = ->
      updateScrollBarWidth()
      moveData()
      # data = MeltCurveService.optimizeForResolution(PARSED_DATA, resolution)
      # console.log data
      # $scope.data = data

    updateScrollBarWidth = ->
      scrollbar_width = $('#melt-curve-scrollbar').width()
      new_width = scrollbar_width * ((10 - $scope.mc_zoom)/10)
      $('#melt-curve-scrollbar .scrollbar').css('width', "#{new_width}px")

    moveData = ->
      data = OPTIMIZED_DATA[$scope.mc_zoom]
      resolution = $scope.resolutionOptions[$scope.mc_zoom]
      data_length = PARSED_DATA['well_0'].length
      $scope.data = MeltCurveService.moveData(data, data_length, resolution, $scope.mc_scroll)

    $scope.$watch 'RunExperimentCtrl.chart', (chart) ->
      if chart is 'melt-curve' and !has_data
        getExperiment (exp) ->
          getMeltCurveData (data) ->
            updateButtonTms(data)

            MeltCurveService.parseData(data.melt_curve_data).then (data) ->
              $scope.data = data

              $timeout ->
                y_extrems = MeltCurveService.getYExtrems(data, $scope.curve_type)
                updateConfigs
                  axes:
                    y:
                      min: y_extrems.min
                      max: y_extrems.max

                has_data = true
                PARSED_DATA = angular.copy(data)
                updateResolutionOptions(data)
                changeResolution()
                $timeout ->
                  $scope.fetching = false
                  console.log '$scope.fetching = false'
                1000

                $timeout ->
                  $scope.$broadcast '$reload:n3:charts'
                , 2000

              , 1000
      else
        $timeout ->
          $scope.$broadcast '$reload:n3:charts'
        , 500

    $scope.$watch ->
      $scope.curve_type
    , (type) ->
      return if !PARSED_DATA
      return if $scope.RunExperimentCtrl.chart isnt 'melt-curve'
      y_extrems = MeltCurveService.getYExtrems(PARSED_DATA, type)
      updateConfigs
        axes:
          y:
            min: y_extrems.min
            max: y_extrems.max

      updateSeries()

      $timeout ->
        $scope.$broadcast '$reload:n3:charts'
      , 1000

    $scope.$watch ->
      $scope.mc_zoom
    , (val) ->
      return if !PARSED_DATA
      changeResolution()

    $scope.$watchCollection 'wellButtons', (buttons) ->
      return if !buttons
      updateSeries(buttons)

    $scope.$watch ->
      Math.round($scope.mc_scroll*100) / 100
      # $scope.mc_scroll
    , (val, oldVal) ->
      return if val == oldVal
      return if !PARSED_DATA
      moveData()

]
