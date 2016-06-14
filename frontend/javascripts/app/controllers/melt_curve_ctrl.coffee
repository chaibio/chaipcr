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
      zoom_calibration = 10
      zoom_unit = Math.ceil(data['well_0'].length/zoom_calibration)
      # zoom_unit = Math.ceil(zoom_unit)
      $scope.resolutionOptions = []
      for i in [zoom_calibration..1] by -1
        $scope.resolutionOptions.push(zoom_unit*i)

      OPTIMIZED_DATA = MeltCurveService.optimizeForEachResolution(PARSED_DATA, $scope.resolutionOptions)
      # console.log OPTIMIZED_DATA

    changeResolution = ->
      updateScrollBarWidth()
      moveData()
      # data = MeltCurveService.optimizeForResolution(PARSED_DATA, resolution)
      # console.log data
      # $scope.data = data

    updateScrollBarWidth = ->
      scrollbar_width = $('#melt-curve-scrollbar').width()
      # console.log "scroll width: #{scrollbar_width}"
      new_width = scrollbar_width * ((10 - $scope.mc_zoom)/10)
      $('#melt-curve-scrollbar .scrollbar').css('width', "#{new_width}px")

    moveData = ->
      data = OPTIMIZED_DATA[$scope.mc_zoom]
      resolution = $scope.resolutionOptions[$scope.mc_zoom]
      data_length = PARSED_DATA['well_0'].length
      $scope.data = MeltCurveService.moveData(data, data_length, resolution, $scope.mc_scroll)
      console.log "data_length: #{$scope.data.well_0.length}"

    $scope.$watch 'RunExperimentCtrl.chart', (chart) ->
      if chart is 'melt-curve' and !has_data
        getExperiment (exp) ->
          getMeltCurveData (data) ->
            console.log 'melt curve data loaded'
            console.log data

            MeltCurveService.parseData(data.melt_curve_data).then (data) ->
              $scope.data = data

              $timeout ->
                y_extrems = MeltCurveService.getYExtrems(data, $scope.curve_type)
                console.log y_extrems
                updateConfigs
                  axes:
                    y:
                      min: y_extrems.min
                      max: y_extrems.max

                has_data = true
                $scope.loading = false
                PARSED_DATA = angular.copy(data)
                updateResolutionOptions(data)
                changeResolution()
              , 1000

    $scope.$watch ->
      $scope.curve_type
    , (type) ->
      return if !PARSED_DATA
      return if $scope.RunExperimentCtrl.chart isnt 'melt-curve'
      y_extrems = MeltCurveService.getYExtrems(PARSED_DATA, type)
      console.log y_extrems
      updateConfigs
        axes:
          y:
            min: y_extrems.min
            max: y_extrems.max

      $timeout ->
        $scope.$broadcast '$reload:n3:charts'
      , 3000

    $scope.$watch ->
      $scope.mc_zoom
    , (val) ->
      return if !PARSED_DATA
      changeResolution()

    $scope.$watch ->
      Math.round($scope.mc_scroll*100) / 100
      # $scope.mc_scroll
    , (val, oldVal) ->
      return if val == oldVal
      return if !PARSED_DATA
      moveData()

]
