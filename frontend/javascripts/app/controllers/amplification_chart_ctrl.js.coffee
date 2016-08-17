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
window.ChaiBioTech.ngApp.controller 'AmplificationChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  'AmplificationChartHelper'
  'Status'
  'expName'
  '$rootScope'
  '$timeout'
  '$interval'
  'Device'
  ($scope, $stateParams, Experiment, helper, Status, expName, $rootScope, $timeout, $interval, Device) ->

    Device.isDualChannel().then (is_dual_channel) ->
      $scope.is_dual_channel = is_dual_channel

      hasInit = false
      drag_scroll = $('#ampli-drag-scroll')
      $scope.chartConfig = helper.chartConfig($scope.is_dual_channel)
      $scope.chartConfig.axes.x.ticks = helper.Xticks $stateParams.max_cycle || 1
      $scope.chartConfig.axes.x.max = $stateParams.max_cycle || 1
      $scope.data = helper.paddData()
      $scope.COLORS = helper.COLORS
      $scope.amplification_data = null
      max_calibration = null
      AMPLI_DATA_CACHE = null
      retryInterval = null
      $scope.baseline_subtraction = true
      $scope.curve_type = 'log'
      $scope.color_by = 'well'
      $scope.retrying = false
      $scope.retry = 0
      $scope.fetching = false
      $scope.channel_1 = true
      $scope.channel_2 = if is_dual_channel then true else false
      $scope.ampli_zoom = {
        value: 0
        width: 0.2
      }

      $scope.$on 'expName:Updated', ->
        $scope.experiment?.name = expName.name

      Experiment.get(id: $stateParams.id).then (data) ->
        maxCycle = helper.getMaxExperimentCycle data.experiment
        $scope.maxCycle = maxCycle
        $scope.chartConfig.axes.x.ticks = helper.Xticks 1, maxCycle
        $scope.chartConfig.axes.x.max = maxCycle
        $scope.experiment = data.experiment

      retry = ->
        $scope.retrying = true
        $scope.retry = 10
        retryInterval = $interval ->
          $scope.retry = $scope.retry - 1
          if $scope.retry is 0
            $interval.cancel(retryInterval)
            $scope.retrying = false
            $scope.error = null
            fetchFluorescenceData()
        , 1000

      fetchFluorescenceData = ->
        gofetch = true
        gofetch = false if $scope.fetching
        gofetch = false if $scope.RunExperimentCtrl.chart isnt 'amplification'
        gofetch = false if $scope.retrying

        if gofetch
          hasInit = true
          $scope.fetching = true

          Experiment
          .getAmplificationData($stateParams.id)
          .then (resp) ->
            $scope.fetching = false
            $scope.error = null
            if resp.status is 200 and resp.data?.partial
              $scope.hasData = true
              $scope.amplification_data = helper.paddData()
              delete $scope.chartConfig.axes.x.min
            if resp.data.amplification_data and resp.data.amplification_data?.length > 1
              $scope.chartConfig.axes.x.min = 1
              $scope.hasData = true
              data = resp.data
              data.amplification_data.shift()
              data.ct.shift()
              max_calibration = helper.getMaxCalibrations(data.amplification_data)
              data.amplification_data = helper.neutralizeData(data.amplification_data, $scope.is_dual_channel)

              AMPLI_DATA_CACHE = angular.copy data
              $scope.amplification_data = angular.copy(AMPLI_DATA_CACHE.amplification_data)
              # updateScrollBarWidth()
              updateButtonCts()

            if ((resp.data?.partial is true) or (resp.status is 202)) and !$scope.retrying
              retry()

          .catch (resp) ->
            return if $scope.retrying
            if resp.status is 500
              $scope.error = 'Internal Server Error'
            $scope.fetching = false
            retry()

      fetchFluorescenceData()

      updateButtonCts = ->
        for well_i in [0..15] by 1
          cts = _.filter AMPLI_DATA_CACHE.ct, (ct) ->
            ct[1] is well_i+1
          $scope.wellButtons["well_#{well_i}"].ct = [cts[0][2]]
          $scope.wellButtons["well_#{well_i}"].ct.push cts[1][2] if cts[1]

      updateDragScrollWidth = ->
        return if $scope.RunExperimentCtrl.chart isnt 'amplification'
        svg = drag_scroll.find('svg')
        return if svg.length is 0
        drag_scroll_width = svg.width() - svg.find('g.y-axis').first()[0].getBBox().width*2
        num_cycle_to_show = $scope.maxCycle - $scope.ampli_zoom
        width_per_cycle = drag_scroll_width/num_cycle_to_show
        w = width_per_cycle * $scope.maxCycle
        drag_scroll.attr 'width', Math.round w

      updateChartData = (data) ->
        return if !data
        subtraction_type = if $scope.baseline_subtraction then 'baseline' else 'background'
        $scope.chartConfig.axes.x.min = data.min_cycle
        $scope.chartConfig.axes.x.max = data.max_cycle
        $scope.chartConfig.axes.x.ticks = helper.Xticks data.min_cycle, data.max_cycle
        if max_calibration isnt null
          $scope.chartConfig.axes.y.max = if $scope.baseline_subtraction then max_calibration.baseline else max_calibration.background

        # $scope.chartConfig.axes.y.scale = $scope.curve_type
        # $scope.data = data.amplification_data
        # $timeout ->
        #   $scope.$broadcast '$reload:n3:charts'
        # , 500

      updateSeries = (buttons) ->
        buttons = buttons || $scope.wellButtons || {}
        $scope.chartConfig.series = []
        subtraction_type = if $scope.baseline_subtraction then 'baseline' else 'background'
        channel_count = if $scope.is_dual_channel then 2 else 1
        channel_end = if $scope.channel_1 && $scope.channel_2 then 2 else if $scope.channel_1 && !$scope.channel_2 then 1 else if !$scope.channel_1 && $scope.channel_2 then 2
        channel_start = if $scope.channel_1 && $scope.channel_2 then 1 else if $scope.channel_1 && !$scope.channel_2 then 1 else if !$scope.channel_1 && $scope.channel_2 then 2
        for ch_i in [channel_start..channel_end] by 1
          for i in [0..15] by 1
            if buttons["well_#{i}"]?.selected
              $scope.chartConfig.series.push
                # axis: 'y'
                dataset: "channel_#{ch_i}"
                # key: "well_#{i}_#{subtraction_type}#{if $scope.curve_type is 'log' then '_log' else ''}"
                x: 'cycle_num'
                y: "well_#{i}_#{subtraction_type}#{if $scope.curve_type is 'log' then '_log' else ''}"
                label: if ($scope.is_dual_channel and $scope.color_by is 'well') then "channel_#{ch_i}, well_#{i+1}: " else "well_#{i+1}: "
                color: if ($scope.color_by is 'well') then buttons["well_#{i}"].color else (if ch_i is 1 then '#00AEEF' else '#8FC742')
                interpolation: {mode: 'cardinal', tension: 0.7}

      updateScrollBarWidth = ->
        return if !angular.isNumber($scope.ampli_zoom) or !AMPLI_DATA_CACHE or !$scope.maxCycle
        num_cycle_to_show = $scope.maxCycle - $scope.ampli_zoom
        wRatio = num_cycle_to_show / $scope.maxCycle
        $scope.scrollbar_width = wRatio;
        # scrollbar_width = $('#ampli-scrollbar').width()
        # new_width = scrollbar_width * wRatio
        # new_width = if new_width > 10 then new_width else 10
        # $('#ampli-scrollbar .scrollbar').css(width: new_width + 'px')
        # $rootScope.$broadcast 'scrollbar:width:changed', 'ampli-scrollbar'

        # $scope.amplification_data = helper.updateScrollBarWidth AMPLI_DATA_CACHE.amplification_data, num_cycle_to_show, $scope.ampli_scroll, $scope.maxCycle
        updateChartData($scope.amplification_data)

      $scope.onZoom = (transform, w, h, scale_extent) ->
        # console.log transform, w, h, scale_extent
        $scope.ampli_scroll = {
          value: Math.abs(transform.x/(w*transform.k - w))
          width: w/(w*transform.k)
        }
        $scope.ampli_zoom = {
          value: (transform.k - 1)/ (scale_extent-1)
          width: 0.2
        }

      $scope.$watchCollection 'ampli_scroll', (scroll_state) ->


      $scope.$watch 'baseline_subtraction', (val) ->
        # updateScrollBarWidth()
        updateChartData($scope.amplification_data)
        updateSeries()

      $scope.$watch 'channel_1', (val) ->
        updateSeries()

      $scope.$watch 'channel_2', (val) ->
        updateSeries()

      $scope.$watch 'curve_type', (type) ->
        # $scope.chartConfig.axes.y.type = type
        $scope.chartConfig.axes.y.scale = type
        updateSeries()
        # if type is 'log'
        #   subtraction_type = if $scope.baseline_subtraction then 'baseline' else 'background'
        #   $scope.chartConfig.axes.y.ticks = helper.getLogViewYticks(max_calibration[subtraction_type])
        #   $scope.chartConfig.axes.y.tickFormat = helper.toScientificNotation
        #   $scope.chartConfig.axes.y.min = 10
        # else
        #   $scope.chartConfig.axes.y.ticks = 10
        #   delete $scope.chartConfig.axes.y.tickFormat

      $scope.$watchCollection 'wellButtons', updateSeries

      $scope.$watch ->
        $scope.RunExperimentCtrl.chart
      , (chart) ->
        if chart is 'amplification'
          if !hasInit
            fetchFluorescenceData()

          $timeout ->
            $scope.$broadcast '$reload:n3:charts'
          , 1000

      $scope.$on '$destroy', ->
        $interval.cancel(retryInterval) if retryInterval


]
