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
window.ChaiBioTech.ngApp.controller 'StandardCurveChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  'StandardCurveChartHelper'
  'expName'
  '$interval'
  'Device'
  '$timeout'
  '$rootScope'
  'focus'
  ($scope, $stateParams, Experiment, helper, expName, $interval, Device, $timeout, $rootScope, focus ) ->

    Device.isDualChannel().then (is_dual_channel) ->
      $scope.is_dual_channel = is_dual_channel

      $scope.chartConfig = helper.chartConfig()
      $scope.chartConfig.channels = if is_dual_channel then 2 else 1
      # $scope.chartConfig.axes.x.max = 1
      $scope.standardcurve_data = helper.paddData($scope.is_dual_channel)
      $scope.well_data = []
      $scope.line_data = {target_line: []}

      $scope.COLORS = helper.SAMPLE_TARGET_COLORS
      $scope.WELL_COLORS = helper.COLORS      
      AMPLI_DATA_CACHE = null
      retryInterval = null
      $scope.baseline_subtraction = true
      $scope.color_by = 'well'
      $scope.retrying = false
      $scope.retry = 0
      $scope.fetching = false
      $scope.channel_1 = true
      $scope.channel_2 = if is_dual_channel then true else false
      $scope.standardcurve_zoom = 0
      $scope.showOptions = true
      $scope.isError = false
      $scope.samples = []
      $scope.types = []
      $scope.targets = []
      $scope.targetsSet = []
      $scope.targetsSetHided = []
      $scope.omittedIndexes = []
      $scope.well_targets = []

      $scope.label_effic = ''
      $scope.label_r2 = ''
      $scope.label_slope = ''
      $scope.label_yint = ''

      $scope.index_target = 0
      $scope.index_channel = -1
      $scope.label_sample = null
      $scope.label_target = "No Selection"
      $scope.label_well = "No Selection"
      $scope.label_channel = ""
      $scope.label_plot = null

      $scope.has_init = false
      $scope.re_init_chart_data = false
      $scope.init_sample_color = '#ccc'

      $scope.line_bgcolor_target = {
        'background-color':'#666666'
      }

      $scope.plot_bgcolor_target = {
        'background-color':'#666666'
      }

      last_well_number = 0
      last_target_channel = 0
      last_target_assigned = 0

      $scope.registerOutsideHover = false;
      unhighlight_event = ''

      if !$scope.registerOutsideHover
        $scope.registerOutsideHover = angular.element(window).on 'mousemove', (e)->
          if !angular.element(e.target).parents('.well-switch').length and !angular.element(e.target).parents('.well-item-row').length 
            if unhighlight_event
              $rootScope.$broadcast unhighlight_event, {}
              unhighlight_event = ''
              last_well_number = 0
              last_target_channel = 0
              last_target_assigned = 0

          $scope.$apply()
      
      $scope.toggleOmitIndex = (well_item) ->
        return if $scope.re_init_chart_data
        omit_index = well_item.well_num.toString() + '_' + well_item.channel.toString()
        if $scope.omittedIndexes.indexOf(omit_index) != -1
          $scope.omittedIndexes.splice $scope.omittedIndexes.indexOf(omit_index), 1
        else
          $scope.omittedIndexes.push omit_index

        well_item.omit = if well_item.omit then 0 else 1

        omitTargetLink = [] 
        omitTargetLink. push
          well_num: well_item.well_num,
          omit: well_item.omit

        Experiment.linkTarget($stateParams.id, well_item.target_id, { wells: omitTargetLink }).then (data) ->
          reInitChartData()

      getWellDataIndex = (well_num, channel) ->
        return well_num.toString() + '_' + channel

      reInitChartData = ->
        $scope.chartConfig.line_series = []
        $scope.chartConfig.series = []

        $scope.retrying = false
        $scope.retry = 0
        $scope.fetching = false
        $scope.hasData = false
        $scope.error = null
        $scope.has_init = false
        $scope.re_init_chart_data = true

        $scope.well_targets = []
        Experiment.getWellLayout($stateParams.id).then (resp) ->
          for i in [0...resp.data.length]
            $scope.samples[i] = if resp.data[i].samples then resp.data[i].samples[0] else null
            if $scope.samples[i]
              for j in [0...$scope.expSamples.length]
                if $scope.samples[i].id == $scope.expSamples[j].id
                  $scope.samples[i].color = $scope.COLORS[j % $scope.COLORS.length]
                  break
                else
                  $scope.samples[i].color = $scope.init_sample_color
            if $scope.is_dual_channel
              $scope.well_targets[2*i] = if resp.data[i].targets && resp.data[i].targets[0] then resp.data[i].targets[0]  else null
              $scope.well_targets[2*i+1] = if resp.data[i].targets && resp.data[i].targets[1] then resp.data[i].targets[1] else null

              if $scope.well_targets[2*i]
                $scope.well_targets[2*i].color = if $scope.well_targets[2*i] then $scope.lookupTargets[$scope.well_targets[2*i].id] else 'transparent'
              if $scope.well_targets[2*i+1]
                $scope.well_targets[2*i+1].color = if $scope.well_targets[2*i+1] then $scope.lookupTargets[$scope.well_targets[2*i+1].id] else 'transparent'
            else
              $scope.well_targets[i] = if resp.data[i].targets && resp.data[i].targets[0] then resp.data[i].targets[0]  else null
              if $scope.well_targets[i]
                $scope.well_targets[i].color = if $scope.well_targets[i] then $scope.lookupTargets[$scope.well_targets[i].id] else 'transparent'

          fetchFluorescenceData()

      $scope.updateTargetsSet = ->
        # $scope.targetsSet = []
        for i in [0...$scope.targets.length]
          if $scope.targets[i]?.id
            target = _.filter $scope.targetsSet, (target) ->
              target.id is $scope.targets[i].id
            if !target.length
              $scope.targetsSet.push($scope.targets[i])

        for i in [$scope.targetsSet.length-1..0] by -1
          if $scope.targetsSet[i]?.id
            target = _.filter $scope.targets, (item) ->
              item.id is $scope.targetsSet[i].id
            if !target.length
              $scope.targetsSet.splice(i, 1)

      $scope.$watchCollection 'targetsSetHided', ->        
        updateSeries() if $scope.hasData
      
      $scope.$on 'event:switch-chart-well', (e, data, oldData) ->
        if !data.active
          $scope.onUnselectLine()
        channel_count = if $scope.is_dual_channel then 2 else 1
        wellScrollTop = (data.index * channel_count + channel_count) * 36 - document.querySelector('.table-container').offsetHeight
        angular.element(document.querySelector('.table-container')).animate { scrollTop: wellScrollTop }, 'fast'

      Experiment.get(id: $stateParams.id).then (data) ->
        maxCycle = helper.getMaxExperimentCycle(data.experiment)
        # $scope.chartConfig.axes.x.max = 1
        $scope.experiment = data.experiment

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
        $scope.retrying = true
        $scope.retry = 5
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
        gofetch = false if $scope.$parent.chart isnt 'standard-curve'
        gofetch = false if $scope.retrying
        
        if gofetch
          $scope.has_init = true
          $scope.fetching = true
          
          Experiment
          .getStandardCurveData($stateParams.id)
          .then (resp) ->
            $scope.fetching = false
            $scope.error = null

            if (resp.status is 200 and !resp.data.partial)
              $scope.hasData = true
              $scope.standardcurve_data = helper.paddData($scope.is_dual_channel)
            if (resp.status is 200 and resp.data?.partial and $scope.enterState)
              $scope.hasData = false
            if resp.status is 200 and !resp.data.partial
              $rootScope.$broadcast 'complete'
            if $scope.hasData and (resp.data.steps?[0].amplification_data and resp.data.steps?[0].amplification_data?.length > 1)
              
              # $scope.chartConfig.axes.x.min = 0
              data = resp.data.steps[0]

              $scope.well_data = helper.normalizeSummaryData(data.summary_data, data.targets, $scope.well_targets)
              $scope.targets = helper.normalizeWellTargetData($scope.well_data, $scope.targets, $scope.is_dual_channel)
              data.summary_data = helper.initialSummaryData(data.summary_data, data.targets)

              $scope.omittedIndexes = []
              for well, i in $scope.well_data by 1
                if well.omit
                  $scope.omittedIndexes.push(getWellDataIndex(well.well_num, well.channel))

              if !$scope.re_init_chart_data
                for i in [0..$scope.targets.length - 1] by 1
                  $scope.targetsSetHided[$scope.targets[i]?.id] = true  if $scope.targetsSetHided[$scope.targets[i]?.id] is undefined

              AMPLI_DATA_CACHE = angular.copy data

              $scope.standardcurve_data = helper.neutralizeChartData(data.summary_data, data.targets, $scope.targets, $scope.is_dual_channel)
              $scope.line_data = helper.neutralizeLineData(data.targets)

              minQt = if $scope.well_data[0] then $scope.well_data[0].quantity else 0
              maxQt = 0
              minCq = if $scope.well_data[0] then $scope.well_data[0].cq else 0
              maxCq = 0

              for well_item in $scope.well_data by 1
                if well_item.quantity <= minQt and well_item.quantity then minQt = well_item.quantity
                if well_item.quantity >= maxQt and well_item.quantity then maxQt = well_item.quantity
                if well_item.cq <= minCq and well_item.cq then minCq = well_item.cq
                if well_item.cq >= maxCq and well_item.cq then maxCq = well_item.cq

              maxQt = Math.log10(maxQt)
              minQt = Math.log10(minQt)
              gapX = maxQt - minQt
              gapY = maxCq - minCq


              $scope.chartConfig.axes.x.min = if Math.floor(minQt) is minQt then minQt - 1 else Math.floor(minQt)
              $scope.chartConfig.axes.x.max = if Math.ceil(maxQt) is maxQt then maxQt + 1 else Math.ceil(maxQt)
              $scope.chartConfig.axes.y.min = minCq
              $scope.chartConfig.axes.y.max = maxCq

              $scope.updateTargetsSet()
              updateButtonCts()
              updateSeries()

              if !(($scope.experiment?.completion_status && $scope.experiment?.completed_at) or $scope.enterState)
                $scope.retrying = true

            if ((resp.data?.partial is true) or (resp.status is 202)) and !$scope.retrying
              retry()
            else
              $scope.re_init_chart_data = false              

          .catch (resp) ->
            if resp.status is 500
              $scope.error = resp.statusText || 'Unknown error'
            $scope.fetching = false
            return if $scope.retrying
            retry()
        else
          retry()

      updateButtonCts = ->
        for well_i in [0..15] by 1
          channel_1_well = _.find $scope.well_data, (item) ->
            item.well_num is well_i+1 and item.channel is 1

          channel_2_well = _.find $scope.well_data, (item) ->
            item.well_num is well_i+1 and item.channel is 2

          $scope.wellButtons["well_#{well_i}"].well_type = []
          $scope.wellButtons["well_#{well_i}"].well_type.push(if channel_1_well then channel_1_well.well_type else '')
          $scope.wellButtons["well_#{well_i}"].well_type.push(if channel_2_well then channel_2_well.well_type else '')

          cts = _.filter AMPLI_DATA_CACHE.summary_data, (ct) ->
            ct[1] is well_i+1

          $scope.wellButtons["well_#{well_i}"].ct = []
          for ct_i in [0..cts.length - 1] by 1
            $scope.wellButtons["well_#{well_i}"].ct.push(cts[ct_i][3])
        return

      updateSeries = (buttons) ->
        buttons = buttons || $scope.wellButtons || {}
        $scope.chartConfig.series = []
        nonGreySeries = []
        channel_count = if $scope.is_dual_channel then 2 else 1
        channel_end = if $scope.channel_1 && $scope.channel_2 then 2 else if $scope.channel_1 && !$scope.channel_2 then 1 else if !$scope.channel_1 && $scope.channel_2 then 2
        channel_start = if $scope.channel_1 && $scope.channel_2 then 1 else if $scope.channel_1 && !$scope.channel_2 then 1 else if !$scope.channel_1 && $scope.channel_2 then 2

        $scope.chartConfig.line_series = []
        for i in [0..$scope.line_data['target_line'].length - 1] by 1
          well_color = '#c5c5c5'
          if $scope.targetsSetHided[$scope.line_data['target_line'][i].id]
            if $scope.color_by is 'target'
              target = _.filter $scope.targets, (target) ->
                target && target.id is $scope.line_data['target_line'][i].id
              if target.length
                well_color = target[0].color
          else
            well_color = 'transparent'
          $scope.line_data['target_line'][i].color = well_color

        for ch_i in [channel_start..channel_end] by 1
          for i in [0..15] by 1            
            if $scope.omittedIndexes.indexOf(getWellDataIndex(i + 1, ch_i)) == -1
              # alert(i)
              if buttons["well_#{i}"]?.selected and $scope.targets[i * channel_count + (ch_i - 1)] and $scope.targets[i * channel_count + (ch_i - 1)].id and $scope.targetsSetHided[$scope.targets[i * channel_count + (ch_i - 1)].id]
                if $scope.color_by is 'well'
                  well_color = buttons["well_#{i}"].color
                else if $scope.color_by is 'target'
                  well_color = if $scope.targets[(ch_i - 1)+i*channel_count] then $scope.targets[(ch_i - 1)+i*channel_count].color else 'transparent'
                else if $scope.color_by is 'sample'
                  well_color = if $scope.samples[i] then $scope.samples[i].color else $scope.init_sample_color
                  if ($scope.is_dual_channel and !$scope.targets[i*channel_count].id and !$scope.targets[i*channel_count+1].id) or (!$scope.is_dual_channel and !$scope.targets[i].id)
                    well_color = 'transparent'
                else if ch_i is 1
                  well_color = '#00AEEF'
                else
                  well_color = '#8FC742'

                continue if $scope.standardcurve_data["well_#{i}_#{ch_i}"][0] is undefined or Math.abs($scope.standardcurve_data["well_#{i}_#{ch_i}"][0]['log_quantity']) is Number.POSITIVE_INFINITY
                if $scope.color_by is 'sample'
                  if well_color is $scope.init_sample_color
                    $scope.chartConfig.series.push
                      dataset: "well_#{i}_#{ch_i}"
                      x: 'log_quantity'
                      y: "cq"
                      color: well_color
                      cq: $scope.wellButtons["well_#{i}"]?.ct
                      well: i
                      channel: ch_i
                      well_type: $scope.targets[i * channel_count + (ch_i - 1)].well_type
                      target_id: $scope.targets[i * channel_count + (ch_i - 1)].id
                  else
                    nonGreySeries.push
                      dataset: "well_#{i}_#{ch_i}"
                      x: 'log_quantity'
                      y: "cq"
                      color: well_color
                      cq: $scope.wellButtons["well_#{i}"]?.ct
                      well: i
                      channel: ch_i
                      well_type: $scope.targets[i * channel_count + (ch_i - 1)].well_type
                      target_id: $scope.targets[i * channel_count + (ch_i - 1)].id
                else
                  $scope.chartConfig.series.push
                    dataset: "well_#{i}_#{ch_i}"
                    x: 'log_quantity'
                    y: "cq"
                    color: well_color
                    cq: $scope.wellButtons["well_#{i}"]?.ct
                    well: i
                    channel: ch_i
                    well_type: $scope.targets[i * channel_count + (ch_i - 1)].well_type
                    target_id: $scope.targets[i * channel_count + (ch_i - 1)].id
            else
              $scope.onUnselectPlot()

        if $scope.color_by is 'sample'
          for i in [0..nonGreySeries.length - 1] by 1
            $scope.chartConfig.series.push(nonGreySeries[i])

      getWellDataIndex = (well_num, channel) ->
        for i in [0..$scope.well_data.length - 1] by 1
          if $scope.well_data[i].well_num is well_num and $scope.well_data[i].channel is channel
            return i
        return -1

      $scope.onUpdateProperties = (line_config) ->
        $scope.label_effic = line_config.efficiency
        $scope.label_r2 = line_config.r2
        $scope.label_slope = line_config.slope
        $scope.label_yint = line_config.offset
        target = _.filter $scope.targets, (target) ->
          target && target.id is line_config.id

        if target.length
          $scope.label_well = target[0].name
          $scope.label_channel = target[0].channel          
        $scope.line_bgcolor_target = { 'background-color':'black' }
        for well_i in [0..$scope.well_data.length - 1]
          $scope.well_data[well_i].active = false

        for i in [0..15] by 1
          $scope.wellButtons["well_#{i}"].active = false

      $scope.onHighlightPlots = (configs, well_index) ->

        for well_i in [0..$scope.well_data.length - 1]
          $scope.well_data[well_i].active = false
          $scope.well_data[well_i].highlight = false

        for well_i in [0..$scope.well_data.length - 1]
          omit_index = $scope.well_data[well_i].well_num.toString() + '_' + $scope.well_data[well_i].channel.toString()
          for config, i in configs by 1
            if ($scope.well_data[well_i].well_num - 1 == config.config.well and $scope.well_data[well_i].channel == config.config.channel) and ($scope.omittedIndexes.indexOf(omit_index) == -1)
              $scope.well_data[well_i].highlight = true

        dual_value = if $scope.is_dual_channel then 2 else 1

        for i in [0..15] by 1
          $scope.wellButtons["well_#{i}"].active = (i == well_index)

        if configs[0]
          config = configs[0].config
          wellScrollTop = (config.well * dual_value + config.channel - 1 + dual_value) * 36 - document.querySelector('.detail-mode-table tbody').offsetHeight
          angular.element('.detail-mode-table tbody').animate { scrollTop: wellScrollTop }, 'fast'

        return

      $scope.onUnHighlightPlots = () ->
        $scope.onUnselectPlot()
        return

      $scope.onHoverPlot = (plot_config, well_index) ->
        $scope.onUnselectPlot()
        $scope.label_plot = plot_config
        if $scope.label_plot
          if $scope.label_plot.well < 8 
            $scope.label_plot.well_label = 'A' + ($scope.label_plot.well + 1) 
          else 
            $scope.label_plot.well_label = 'B' + ($scope.label_plot.well - 7) 

          for well_i in [0..$scope.well_data.length - 1]
            $scope.well_data[well_i].active = false
            $scope.well_data[well_i].highlight = false

            omit_index = $scope.well_data[well_i].well_num.toString() + '_' + $scope.well_data[well_i].channel.toString()
            if ($scope.well_data[well_i].well_num - 1 == plot_config.well and $scope.well_data[well_i].channel == plot_config.channel) and ($scope.omittedIndexes.indexOf(omit_index) == -1)
              $scope.well_data[well_i].highlight = true

          for i in [0..15] by 1
            $scope.wellButtons["well_#{i}"].active = (i == plot_config.well)
        else
          for well_i in [0..$scope.well_data.length - 1]
            $scope.well_data[well_i].active = false
            $scope.well_data[well_i].highlight = false
          for i in [0..15] by 1
            $scope.wellButtons["well_#{i}"].active = false

      $scope.onHoverRow = (event, well_item, index) ->
        is_active_plot = false
        for well_i in [0..$scope.well_data.length - 1]
          if $scope.well_data[well_i].active
            is_active_plot = true
            break

        if is_active_plot or (last_well_number == well_item.well_num and last_target_channel == well_item.channel)
          return

        last_well_number = well_item.well_num
        last_target_channel = well_item.channel

        omit_index = well_item.well_num.toString() + '_' + well_item.channel.toString()
        if !$scope.has_init or (($scope.wellButtons['well_' + (well_item.well_num - 1)].selected) and ($scope.omittedIndexes.indexOf(omit_index) == -1) and ($scope.targetsSetHided[$scope.targets[index].id]))
          if !well_item.active
            $rootScope.$broadcast 'event:std-highlight-row', { well_datas: [{well: well_item.well_num, channel: well_item.channel}], well_index: well_item.well_num - 1 }
            unhighlight_event = 'event:std-unhighlight-row'

      $scope.onZoom = (transform, w, h, scale_extent) ->
        $scope.std_scroll = {
          value: Math.abs(transform.x/(w*transform.k - w))
          width: w/(w*transform.k)
        }
        $scope.standardcurve_zoom = (transform.k - 1)/ (scale_extent)


      $scope.zoomIn = ->
        $scope.standardcurve_zoom = Math.min($scope.standardcurve_zoom * 2 || 0.001 * 2, 1)

      $scope.zoomOut = ->
        $scope.standardcurve_zoom = Math.max($scope.standardcurve_zoom * 0.5, 0.001)

      $scope.onSelectWell = (well_item, index) ->
        config = {}
        config.config = {}
        config.config.well = well_item.well_num - 1
        config.config.channel = well_item.channel

        dual_value = if $scope.is_dual_channel then 2 else 1

        omit_index = well_item.well_num.toString() + '_' + well_item.channel.toString()
        if $scope.wellButtons['well_' + (well_item.well_num - 1)].selected and $scope.omittedIndexes.indexOf(omit_index) == -1 and $scope.targetsSetHided[$scope.targets[index].id]
          for well_i in [0..$scope.well_data.length - 1]
            $scope.well_data[well_i].active = ($scope.well_data[well_i].well_num - 1 == config.config.well and $scope.well_data[well_i].channel == config.config.channel)

          for i in [0..15] by 1
            $scope.wellButtons["well_#{i}"].active = (i == config.config.well)
            if(i == config.config.well)
              $scope.index_target = i % 8
              if (i < 8) 
                $scope.index_channel = 1
              else 
                $scope.index_channel = 2

              $scope.label_channel = config.config.channel
              if i < $scope.targets.length
                if $scope.targets[i]!=null
                  $scope.label_target = $scope.targets[config.config.well * dual_value + config.config.channel - 1]
                else
                  $scope.label_target = ""
              else 
                $scope.label_target = ""

              if i < $scope.targets.length
                if $scope.samples[i]!=null
                  $scope.label_sample = $scope.samples[i].name if $scope.samples[i]
                else
                  $scope.label_sample = null
              else 
                $scope.label_sample = null

              # $scope.label_slope = 
              # $scope.label_yint = 
              wells = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8']

        if $scope.label_target.name
          $scope.line_bgcolor_target = { 'background-color':'black' }
        else 
          $scope.line_bgcolor_target = { 'background-color':'#666' }

      $scope.onSelectRow = (well_item, index) ->
        for well_i in [0..$scope.well_data.length - 1]
          $scope.well_data[well_i].highlight = false

        omit_index = well_item.well_num.toString() + '_' + well_item.channel.toString()
        if !$scope.has_init or (($scope.wellButtons['well_' + (well_item.well_num - 1)].selected) and ($scope.omittedIndexes.indexOf(omit_index) == -1) and ($scope.targetsSetHided[$scope.targets[index].id]))
          if !well_item.active
            $rootScope.$broadcast 'event:standard-select-row', {well: well_item.well_num, channel: well_item.channel, well_type: well_item.well_type}
          else
            $rootScope.$broadcast 'event:standard-unselect-row', {well: well_item.well_num, channel: well_item.channel, well_type: well_item.well_type }
            $scope.onUnselectPlot()

      $scope.onSelectPlot = (config) ->
        $scope.plot_bgcolor_target = { 'background-color':'black' }
        $scope.line_bgcolor_target = { 'background-color':'#666666' }
        $scope.label_plot = config
        if $scope.label_plot
          if $scope.label_plot.well < 8 
            $scope.label_plot.well_label = 'A' + ($scope.label_plot.well + 1) 
          else 
            $scope.label_plot.well_label = 'B' + ($scope.label_plot.well - 7) 

        # $scope.line_bgcolor_target = { 'background-color':config.config.color }
        dual_value = if $scope.is_dual_channel then 2 else 1

        for well_i in [0..$scope.well_data.length - 1]
          $scope.well_data[well_i].active = ($scope.well_data[well_i].well_num - 1 == config.well and $scope.well_data[well_i].channel == config.channel)

        for i in [0..15] by 1
          $scope.wellButtons["well_#{i}"].active = (i == config.well)

        wellScrollTop = (config.well * dual_value + config.channel - 1 + dual_value) * 36 - document.querySelector('.table-container').offsetHeight
        angular.element(document.querySelector('.table-container')).animate { scrollTop: wellScrollTop }, 'fast'
          
      $scope.onUnselectLine = ->
        $scope.label_well = "No Selection"
        $scope.label_channel = ""
        $scope.label_effic = ''
        $scope.label_r2 = ''
        $scope.label_slope = ''
        $scope.label_yint = ''
        $scope.line_bgcolor_target = {'background-color':'#666666'}

      $scope.onUnselectPlot = ->
        for well_i in [0..$scope.well_data.length - 1]
          $scope.well_data[well_i]?.active = false
          $scope.well_data[well_i]?.highlight = false

        for i in [0..15] by 1
          $scope.wellButtons["well_#{i}"]?.active = false

        $scope.plot_bgcolor_target = {'background-color':'#666666'}
        $scope.label_plot = null

      $scope.$watchCollection 'wellButtons', ->
        if $scope.hasData
          $scope.onUnselectLine()
          $scope.onUnselectPlot()
          updateSeries()

      $scope.$watch ->
        $scope.$parent.chart
      , (chart) ->
        if chart is 'standard-curve'
          $scope.expTargets = []
          $scope.lookupTargets = []
          Experiment.getTargets($stateParams.id).then (resp_target) ->
            for i in [0...resp_target.data.length]
              $scope.expTargets[i] = resp_target.data[i].target
              $scope.lookupTargets[resp_target.data[i].target.id] = $scope.COLORS[i % $scope.COLORS.length]

            $scope.expSamples = []
            Experiment.getSamples($stateParams.id).then (response) ->
              for i in [0...response.data.length]
                $scope.expSamples[i] = response.data[i].sample

              $scope.well_targets = []
              Experiment.getWellLayout($stateParams.id).then (resp) ->
                for i in [0...resp.data.length]
                  $scope.samples[i] = if resp.data[i].samples then resp.data[i].samples[0] else null
                  if $scope.samples[i]
                    for j in [0...$scope.expSamples.length]
                      if $scope.samples[i].id == $scope.expSamples[j].id
                        $scope.samples[i].color = $scope.COLORS[j % $scope.COLORS.length]
                        break
                      else
                        $scope.samples[i].color = $scope.init_sample_color
                  if $scope.is_dual_channel
                    $scope.well_targets[2*i] = if resp.data[i].targets && resp.data[i].targets[0] then resp.data[i].targets[0]  else null
                    $scope.well_targets[2*i+1] = if resp.data[i].targets && resp.data[i].targets[1] then resp.data[i].targets[1] else null

                    if $scope.well_targets[2*i]
                      $scope.well_targets[2*i].color = if $scope.well_targets[2*i] then $scope.lookupTargets[$scope.well_targets[2*i].id] else 'transparent'
                    if $scope.well_targets[2*i+1]
                      $scope.well_targets[2*i+1].color = if $scope.well_targets[2*i+1] then $scope.lookupTargets[$scope.well_targets[2*i+1].id] else 'transparent'
                  else
                    $scope.well_targets[i] = if resp.data[i].targets && resp.data[i].targets[0] then resp.data[i].targets[0]  else null
                    if $scope.well_targets[i]
                      $scope.well_targets[i].color = if $scope.well_targets[i] then $scope.lookupTargets[$scope.well_targets[i].id] else 'transparent'

                $scope.well_data = helper.blankWellData($scope.is_dual_channel, $scope.well_targets)
                $scope.targets = helper.blankWellTargetData($scope.well_data)
                for i in [0..$scope.targets.length - 1] by 1
                  $scope.targetsSetHided[$scope.targets[i]?.id] = true  if $scope.targetsSetHided[$scope.targets[i]?.id] is undefined

                $scope.omittedIndexes = []
                for well, i in $scope.well_data by 1
                  if well.omit
                    $scope.omittedIndexes.push(getWellDataIndex(well.well_num, well.channel))

                $scope.updateTargetsSet()
                updateSeries()

                fetchFluorescenceData()

              $timeout ->
                $rootScope.$broadcast 'event:start-resize-aspect-ratio'
                $scope.showStandardChart = true
              , 1000
        else
          $scope.showAmpliChart = false
          $scope.showStandardChart = false

      $scope.$on '$destroy', ->
        $interval.cancel(retryInterval) if retryInterval

        # store well buttons
        wellSelections = {}
        for well_i in [0..15] by 1
          wellSelections["well_#{well_i}"] = $scope.wellButtons["well_#{well_i}"].selected

        $.jStorage.set('selectedWells', wellSelections)
        $.jStorage.set('selectedExpId', $stateParams.id)

      $scope.showPlotTypeList = ->
        document.getElementById("plotTypeList").classList.toggle("show")

      $scope.showColorByList = ->
        document.getElementById("colorByList_standard").classList.toggle("show")
      
      $scope.targetClick = (index) ->
        $scope.targetsSetHided[index] = !$scope.targetsSetHided[index]
        updateSeries()

      # $scope.targetGridTop = ->
      #   document.getElementById("curve-plot").clientHeight + 30
      $scope.targetGridTop = ->
        Math.max(document.getElementById("curve-plot").clientHeight + 30, 412 + 30)

]
