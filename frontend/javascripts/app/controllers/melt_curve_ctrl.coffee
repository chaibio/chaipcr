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
  'Device'
  'AmplificationChartHelper'
  ($scope, Experiment, $stateParams, MeltCurveService, $timeout, $interval, $rootScope, focus, Device, helper) ->
    Device.isDualChannel().then (is_dual_channel) ->
      $scope.is_dual_channel = is_dual_channel

      $scope.curve_type = 'derivative'
      $scope.color_by = 'well'
      $scope.config = MeltCurveService.chartConfig()
      $scope.config.channels = if is_dual_channel then 2 else 1
      $scope.data = MeltCurveService.defaultData($scope.is_dual_channel)
      retryInterval = null
      $scope.retrying = false
      $scope.retry = 0
      $scope.fetching = false
      $scope.channel_1 = true
      $scope.channel_2 = if $scope.is_dual_channel then true else false

      $scope.COLORS = helper.SAMPLE_TARGET_COLORS
      $scope.WELL_COLORS = helper.COLORS      

      $scope.mc_zoom = 0
      $scope.well_data = []
      $scope.samples = []
      $scope.types = []
      $scope.targets = []
      $scope.targetsSet = []
      $scope.targetsSetHided = []
      $scope.samplesSet = []
      $scope.omittedIndexes = []
      $scope.well_targets = []

      $scope.label_Temp = ''
      $scope.label_Norm = ''
      $scope.label_dF_dT = ''

      $scope.index_target = 0
      $scope.index_channel = -1
      $scope.label_sample = null
      $scope.label_target = "No Selection"
      $scope.label_well = "No Selection"
      $scope.label_channel = ""

      $scope.has_init = false
      $scope.init_sample_color = '#ccc'

      $scope.bgcolor_target = {
        'background-color':'#666666'
      }
        
      $scope.bgcolor_wellSample = {
        'background-color':'#666666'
      }

      $scope.toggleOmitIndex = (omit_index) ->
      
        if $scope.omittedIndexes.indexOf(omit_index) != -1
          $scope.omittedIndexes.splice $scope.omittedIndexes.indexOf(omit_index), 1
        else
          $scope.omittedIndexes.push omit_index
        updateSeries()

      $scope.$watch '$viewContentLoaded', ->
        $rootScope.$broadcast 'event:start-resize-aspect-ratio'

      $scope.$watchCollection 'targetsSetHided', ->
        updateSeries()

      $scope.updateTargetsSet = ->
        # $scope.targetsSet = []
        for i in [0...$scope.targets.length]
          if $scope.targets[i]?.id
            target = _.filter $scope.targetsSet, (target) ->
              target.id is $scope.targets[i].id
            if !target.length
              $scope.targetsSet.push($scope.targets[i])

        for i in [0...$scope.targetsSet.length]
          if $scope.targetsSet[i]?.id
            target = _.filter $scope.targets, (target) ->
              target.id is $scope.targetsSet[i].id
            if !target.length
              delete $scope.targetsSet[i]

      $scope.updateSamplesSet = ->
        $scope.samplesSet = []

      $scope.$on 'event:switch-chart-well', (e, data, oldData) ->
        if !data.active
          $scope.onUnselectLine()
        channel_count = if $scope.is_dual_channel then 2 else 1
        wellScrollTop = (data.index * channel_count + channel_count) * 36 - document.querySelector('.table-container').offsetHeight
        angular.element(document.querySelector('.table-container')).animate { scrollTop: wellScrollTop }, 'fast'

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
          $scope.has_init = true
          $scope.fetching = true
          $scope.error = null
          
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
        $scope.well_data = MeltCurveService.normalizeSummaryData(data.ramps[0].melt_curve_data, data.targets, $scope.well_targets)
        $scope.targets = MeltCurveService.normalizeWellTargetData($scope.well_data, $scope.is_dual_channel)        

        for i in [0..$scope.targets.length - 1] by 1
          $scope.targetsSetHided[$scope.targets[i]?.id] = true if $scope.targetsSetHided[$scope.targets[i]?.id] is undefined and !isDefaultSwitchDisable($scope.targets[i])

        for well_data, well_i in $scope.well_data by 1
          if $scope.wellButtons["well_#{well_data.well_num - 1}"].ct == undefined
            $scope.wellButtons["well_#{well_data.well_num - 1}"].ct = ['', '']
          $scope.wellButtons["well_#{well_data.well_num - 1}"].ct[well_data.channel - 1] = MeltCurveService.averagedTm(well_data.tm)

        $scope.updateTargetsSet()
        updateSeries()

      updateSeries = ->
        buttons = $scope.wellButtons || {}
        nonGreySeries = []

        $scope.config.series = []
        $scope.config.axes.y.label = 'Fluorescence (' + $scope.curve_type.charAt(0).toUpperCase() + $scope.curve_type.slice(1) + ')'
        $scope.config.box.label.y = if $scope.curve_type is 'derivative' then '-dF/dT' else 'RFU'

        channel_count = if $scope.is_dual_channel then 2 else 1
        channel_end = if $scope.channel_1 && $scope.channel_2 then 2 else if $scope.channel_1 && !$scope.channel_2 then 1 else if !$scope.channel_1 && $scope.channel_2 then 2
        channel_start = if $scope.channel_1 && $scope.channel_2 then 1 else if $scope.channel_1 && !$scope.channel_2 then 1 else if !$scope.channel_1 && $scope.channel_2 then 2

        for ch_i in [channel_start..channel_end] by 1
          for i in [0..15] by 1
            if $scope.omittedIndexes.indexOf(getWellDataIndex(i + 1, ch_i)) == -1
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

                if $scope.color_by is 'sample'
                  if well_color is $scope.init_sample_color
                    $scope.config.series.push
                      selected: buttons["well_#{i}"]?.selected
                      channel: ch_i
                      y: $scope.curve_type
                      x: 'temperature'
                      dataset: "well_#{i}_#{ch_i}"
                      color: well_color
                      ct: buttons["well_#{i}"]?.ct
                      well: i
                  else
                    nonGreySeries.push
                      selected: buttons["well_#{i}"]?.selected
                      channel: ch_i
                      y: $scope.curve_type
                      x: 'temperature'
                      dataset: "well_#{i}_#{ch_i}"
                      color: well_color
                      ct: buttons["well_#{i}"]?.ct
                      well: i
                else
                  $scope.config.series.push
                    selected: buttons["well_#{i}"]?.selected
                    channel: ch_i
                    y: $scope.curve_type
                    x: 'temperature'
                    dataset: "well_#{i}_#{ch_i}"
                    color: well_color
                    ct: buttons["well_#{i}"]?.ct
                    well: i
            else
              $scope.onUnselectLine()

        if $scope.color_by is 'sample'
          for i in [0..nonGreySeries.length - 1] by 1
            $scope.config.series.push(nonGreySeries[i])

      getWellDataIndex = (well_num, channel) ->
        for i in [0..$scope.well_data.length - 1] by 1
          if $scope.well_data[i].well_num is well_num and $scope.well_data[i].channel is channel
            return i
        return -1

      $scope.onUpdateProperties = (temp, norm, dF_dt) ->
        $scope.label_Temp = temp
        $scope.label_Norm = norm
        $scope.label_dF_dT = dF_dt

      getMeltCurveDataCallBack = (data) ->
        updateButtonTms(data)

        chart_data = MeltCurveService.normalizeChartData(data.ramps[0].melt_curve_data, data.targets, $scope.well_targets)
        MeltCurveService.parseData(chart_data, $scope.is_dual_channel).then (data) ->
          $scope.data = data

          $scope.fetching = false
          $scope.hasData = true

      $scope.showPlotTypeList = ->
        document.getElementById("plotTypeList").classList.toggle("show")

      $scope.showColorByList = ->
        document.getElementById("colorByList_ampli").classList.toggle("show")

      $scope.$watch ->
        $scope.$parent.chart
      , (chart) ->
        if chart is 'melt-curve'
          if !$scope.hasData
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
                  
                  $scope.targets = $scope.well_targets
                  for i in [0..$scope.targets.length - 1] by 1
                    $scope.targetsSetHided[$scope.targets[i]?.id] = true if $scope.targetsSetHided[$scope.targets[i]?.id] is undefined and !isDefaultSwitchDisable($scope.targets[i])

                  getMeltCurveData(getMeltCurveDataCallBack)
                  $scope.enterState = false
                  $scope.data = MeltCurveService.defaultData($scope.is_dual_channel)
                  $scope.well_data = MeltCurveService.blankWellData($scope.is_dual_channel, $scope.well_targets)
                  $scope.has_data = false

                  $scope.updateSamplesSet()
                  $scope.updateTargetsSet()

            $timeout ->
              $rootScope.$broadcast 'event:start-resize-aspect-ratio'
              $scope.showMeltCurveChart = true
            , 1000
        else
          $scope.showMeltCurveChart = false

      $scope.$watch ->
        $scope.curve_type
      , (type) ->
        return if $scope.$parent.chart isnt 'melt-curve'

        updateSeries()

      isDefaultSwitchDisable = (target)->
        if $scope.expTargets.length
          target_item = _.filter $scope.expTargets, (elem) ->
            elem.id is target.id
          return (target_item.length && target_item[0].channel == 2) || (!target_item.length && target.name == 'Ch 2')
        else
          return ($scope.expTargets.length == 0 && target.name == 'Ch 2')
        true

      $scope.onZoom = (transform, w, h, scale_extent) ->
        $scope.mc_scroll = {
          value: Math.abs(transform.x/(w*transform.k - w))
          width: w/(w*transform.k)
        }
        $scope.mc_zoom = (transform.k - 1)/ (scale_extent)

      $scope.zoomIn = ->
        $scope.mc_zoom = Math.min($scope.mc_zoom * 2 || 0.001 * 2, 1)

      $scope.zoomOut = ->
        $scope.mc_zoom = Math.max($scope.mc_zoom * 0.5, 0.001)

      $scope.onSelectWell = (well_item, index) ->
        config = {}
        config.config = {}
        config.config.well = well_item.well_num - 1
        config.config.channel = well_item.channel

        dual_value = if $scope.is_dual_channel then 2 else 1

        if $scope.wellButtons['well_' + (well_item.well_num - 1)].selected and $scope.omittedIndexes.indexOf(index) == -1 and $scope.targetsSetHided[$scope.targets[index].id]
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

              wells = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8']
              $scope.label_well = wells[i]

        if $scope.label_target.name
          $scope.bgcolor_target = { 'background-color':'black' }
        else 
          $scope.bgcolor_target = { 'background-color':'#666' }

      $scope.onSelectRow = (well_item, index) ->
        if !$scope.has_init or (($scope.wellButtons['well_' + (well_item.well_num - 1)].selected) and ($scope.omittedIndexes.indexOf(index) == -1) and ($scope.targetsSetHided[$scope.targets[index].id]))
          if !well_item.active
            $rootScope.$broadcast 'event:melt-select-row', {well: well_item.well_num, channel: well_item.channel}
          else
            $rootScope.$broadcast 'event:melt-unselect-row', {well: well_item.well_num, channel: well_item.channel}

      $scope.onSelectLine = (config) ->
        $scope.bgcolor_target = { 'background-color':'black' }
        dual_value = if $scope.is_dual_channel then 2 else 1

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
                $scope.label_target = $scope.targets[config.config.well * 2 + config.config.channel - 1]
              else
                $scope.label_target = ""
            else 
              $scope.label_target = ""

            if i < $scope.targets.length
              if $scope.samples[i]!=null
                $scope.label_sample = $scope.samples[i]?.name
              else
                $scope.label_sample = null
            else 
              $scope.label_sample = null

            wells = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8']
            $scope.label_well = wells[i]

        wellScrollTop = (config.config.well * dual_value + config.config.channel - 1 + dual_value) * 36 - document.querySelector('.table-container').offsetHeight
        angular.element(document.querySelector('.table-container')).animate { scrollTop: wellScrollTop }, 'fast'
          
      $scope.onUnselectLine = ->
        for well_i in [0..$scope.well_data.length - 1]
          $scope.well_data[well_i].active = false

        for i in [0..15] by 1
          $scope.wellButtons["well_#{i}"].active = false

        $scope.label_target = "No Selection"
        $scope.label_well = "No Selection"
        $scope.label_channel = ""

        $scope.label_Temp = ''
        $scope.label_Norm = ''
        $scope.label_dF_dT = ''

        $scope.label_sample = null
        $scope.bgcolor_target = {
          'background-color':'#666666'
        }
        $scope.bgcolor_wellSample = {
          'background-color':'#666666'
        }

      $scope.$watchCollection 'wellButtons', (buttons) ->
        return if !buttons
        updateSeries()

      $scope.$on '$destroy', ->
        $interval.cancel(retryInterval) if retryInterval

    $scope.onChangeSlotType = (type) ->
      $scope.curve_type = type
      $scope.label_Temp = ''
      $scope.label_Norm = ''
      $scope.label_dF_dT = ''
]
