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
  '$rootScope'
  'focus'
  ($scope, Experiment, $stateParams, MeltCurveService, $timeout, $interval, $rootScope, focus) ->

    $scope.curve_type = 'derivative'
    $scope.color_by = 'well'
    $scope.config = MeltCurveService.chartConfig()
    $scope.data = MeltCurveService.defaultData()
    retryInterval = null
    $scope.retrying = false
    $scope.retry = 0
    $scope.fetching = false
    $scope.samples = []
    $scope.editExpNameMode = []

    $scope.focusExpName = (index) ->
      $scope.editExpNameMode[index] = true
      focus('editExpNameMode')

    $scope.updateSampleNameEnter = (well_num, name) ->
      Experiment.updateWell($stateParams.id, well_num + 1, {'well_type':'sample','sample_name':name})
      $scope.editExpNameMode[well_num] = false
      if event.shiftKey
        $scope.focusExpName(well_num - 1)
      else
        $scope.focusExpName(well_num + 1)

    $scope.updateSampleName = (well_num, name) ->
      Experiment.updateWell($stateParams.id, well_num + 1, {'well_type':'sample','sample_name':name})
      $scope.editExpNameMode[well_num] = false

    Experiment.getWells($stateParams.id).then (resp) ->
      for i in [0...16] by 1
        $scope.samples[resp.data[i].well.well_num - 1] = resp.data[i].well.sample_name if resp.data[i]

    $scope.$on 'status:data:updated', (e, data, oldData) ->
      return if !data
      return if !data.experiment_controller
      $scope.statusData = data
      $scope.state = data.experiment_controller.machine.state
      $scope.thermal_state = data.experiment_controller.machine.thermal_state
      $scope.oldState = oldData?.experiment_controller?.machine?.state || 'NONE'
      $scope.isCurrentExp = parseInt(data.experiment_controller.experiment?.id) is parseInt($stateParams.id)
      if $scope.isCurrentExp is true
        $scope.enterState = $scope.isCurrentExp


    retry = ->
      return if $scope.retrying
      $scope.retrying = true
      $scope.retry = 5
      retryInterval = $interval ->
        $scope.retry = $scope.retry - 1
        if $scope.retry is 0
          $interval.cancel(retryInterval)
          $scope.error = null
          $scope.retrying = false
          getMeltCurveData(getMeltCurveDataCallBack)
      , 1000

    getMeltCurveData = (cb) ->
      gofetch = if !$scope.fetching and
                $scope.$parent.chart is 'melt-curve' and
                !$scope.retrying then true else false

      if gofetch
        $scope.fetching = true
        Experiment.getMeltCurveData($stateParams.id)
        .then (resp) ->
          if (resp.data?.partial and $scope.enterState) or (!resp.data.partial)
            $scope.has_data = true
          if !resp.data.partial
            $rootScope.$broadcast 'complete'
          if (cb and resp.data.ramps?[0].melt_curve_data and $scope.enterState) or (cb and resp.data.ramps?[0].melt_curve_data and !resp.data.partial )
            cb(resp.data)
          else
            $scope.fetching = false
          if resp.status is 202 or resp.data?.partial
            retry()

        .catch (resp) ->
          $scope.fetching = false
          if resp.status is 500
            $scope.error = if resp.data?.errors then resp.data.errors else 'Unable to retrieve melt curve data due to some error.'
          retry()

    getExperiment = (cb) ->
      Experiment.get(id: $stateParams.id).then (data) ->
        $scope.experiment = data.experiment
        cb(data.experiment) if !!cb

    updateButtonTms = (data) ->
      for well_data, well_i in data.ramps[0].melt_curve_data by 1
        $scope.wellButtons["well_#{well_i}"].ct = [MeltCurveService.averagedTm(well_data.tm)]

      updateSeries()

    updateSeries = ->
      buttons = $scope.wellButtons || {}

      $scope.config.series = []
      $scope.config.axes.y.label = $scope.curve_type.toUpperCase()
      $scope.config.box.label.y = if $scope.curve_type is 'derivative' then '-dF/dT' else 'RFU'

      for i in [0..15] by 1
        $scope.config.series.push
          selected: buttons["well_#{i}"]?.selected
          channel: 1
          y: $scope.curve_type
          x: 'temperature'
          dataset: "well_#{i}"
          color: buttons["well_#{i}"]?.color
          ct: buttons["well_#{i}"]?.ct
          well: i

    getMeltCurveDataCallBack = (data) ->
      updateButtonTms(data)

      MeltCurveService.parseData(data.ramps[0].melt_curve_data).then (data) ->
        $scope.data = data
        y_extrems = MeltCurveService.getYExtrems(data, $scope.curve_type)

        $scope.fetching = false
        $scope.hasData = true

    $scope.$watch ->
      $scope.$parent.chart
    , (chart) ->
      if chart is 'melt-curve'
        if !$scope.hasData
          getMeltCurveData(getMeltCurveDataCallBack)
          $scope.enterState = false
          $scope.data = MeltCurveService.defaultData()
          $scope.has_data = false
          Experiment.getWells($stateParams.id).then (resp) ->
            for i in [0...16]
              $scope.samples[resp.data[i].well.well_num - 1] = resp.data[i].well.sample_name if resp.data[i]

        $timeout ->
          $scope.showMeltCurveChart = true
        , 1000
      else
        $scope.showMeltCurveChart = false

    $scope.$watch ->
      $scope.curve_type
    , (type) ->
      return if $scope.$parent.chart isnt 'melt-curve'

      updateSeries()

    $scope.onZoom = (transform, w, h, scale_extent) ->
      $scope.mc_scroll = {
        value: Math.abs(transform.x/(w*transform.k - w))
        width: w/(w*transform.k)
      }
      $scope.mc_zoom = (transform.k - 1)/ (scale_extent)

    $scope.onSelectLine = (config) ->
      for i in [0..15] by 1
        $scope.wellButtons["well_#{i}"].active = (i == config.config.well)

    $scope.onUnselectLine = ->
      for i in [0..15] by 1
        $scope.wellButtons["well_#{i}"].active = false

    $scope.$watchCollection 'wellButtons', (buttons) ->
      return if !buttons
      updateSeries()

    $scope.$on '$destroy', ->
      $interval.cancel(retryInterval) if retryInterval

]
