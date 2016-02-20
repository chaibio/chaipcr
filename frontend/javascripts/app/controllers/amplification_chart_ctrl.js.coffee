window.ChaiBioTech.ngApp.controller 'AmplificationChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  'AmplificationChartHelper'
  'Status'
  'expName'
  '$rootScope'
  '$timeout'
  'Device'
  ($scope, $stateParams, Experiment, helper, Status, expName, $rootScope, $timeout, Device) ->

    Device.isDualChannel().then (is_dual_channel) ->
      $scope.is_dual_channel = is_dual_channel

      hasData = false
      hasInit = false
      fetching = false
      drag_scroll = $('#ampli-drag-scroll')
      $scope.chartConfig = helper.chartConfig(is_dual_channel)
      $scope.chartConfig.axes.x.ticks = helper.Xticks $stateParams.max_cycle || 1
      $scope.chartConfig.axes.x.max = $stateParams.max_cycle || 1
      $scope.data = helper.paddData()
      console.log $scope.data
      $scope.log_linear = 'log'
      $scope.COLORS = helper.COLORS
      $scope.amplification_data = null
      AMPLI_DATA_CACHE = null
      MAX_BACKGROUND_AMPLIFICATION = 0
      MAX_BASELINE_AMPLIFICATION = 0
      $scope.baseline_subtraction = true

      $scope.$on 'expName:Updated', ->
        $scope.experiment?.name = expName.name

      Experiment.get(id: $stateParams.id).then (data) ->
        maxCycle = helper.getMaxExperimentCycle data.experiment
        $scope.maxCycle = maxCycle
        $scope.chartConfig.axes.x.ticks = helper.Xticks 1, maxCycle
        $scope.chartConfig.axes.x.max = maxCycle
        $scope.experiment = data.experiment

      $scope.$on 'status:data:updated', (e, data, oldData) ->
        newStep = parseInt(data?.experiment_controller?.expriment?.step?.number) || null
        oldStep = parseInt(oldData?.experiment_controller?.expriment?.step?.number) || null
        state = data?.experiment_controller?.machine?.state
        oldState = oldData?.experiment_controller?.machine?.state
        isCurrentExp = parseInt(data?.experiment_controller?.expriment?.id) is parseInt($stateParams.id)

        if ((state is 'idle' and !!$scope.experiment?.completed_at and !hasData) or
        (state is 'idle' and oldState isnt state) or
        (state is 'running' and (oldStep isnt newStep or !oldStep) and data.optics.collect_data and oldData?.optics.collect_data is 'true') )
          fetchFluorescenceData()

      $scope.$watch ->
        $scope.RunExperimentCtrl.chart
      , (val) ->
        if val is 'amplification' and hasInit
          fetchFluorescenceData()

      fetchFluorescenceData = ->
        # return
        return if $scope.RunExperimentCtrl.chart isnt 'amplification'
        if !fetching
          fetching = true
          hasInit = true

          $timeout ->
            Experiment.getAmplificationData($stateParams.id)
            .then (resp) ->
              data = resp.data
              hasData = true
              return if !data.amplification_data
              return if data.amplification_data.length is 0
              data.amplification_data.shift()
              data.ct.shift()
              MAX_BACKGROUND_AMPLIFICATION = helper.getMaxCalibration(data.amplification_data, 'background')
              MAX_BASELINE_AMPLIFICATION = helper.getMaxCalibration(data.amplification_data, 'baseline')
              data.amplification_data = helper.neutralizeData(data.amplification_data, $scope.is_dual_channel)
              AMPLI_DATA_CACHE = angular.copy data
              $scope.amplification_data = angular.copy AMPLI_DATA_CACHE.amplification_data
              moveData()
              updateButtonCts()

            .finally ->
              fetching = false
          , 1500

      updateButtonCts = ->
        # channel_count = if $scope.is_dual_channel then 2 else 1
        for well_i in [0..15] by 1
          cts = _.filter AMPLI_DATA_CACHE.ct, (ct) ->
            ct[1] is well_i+1
          $scope.wellButtons["well_#{well_i}"].ct = [cts[0][2]]
          $scope.wellButtons["well_#{well_i}"].ct.push cts[1][2] if cts[1]
            # [ct[0][2], ct[1]?[2]]

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
        # $scope.chartConfig.axes.y.max = if subtraction_type is 'baseline' then MAX_BASELINE_AMPLIFICATION else MAX_BACKGROUND_AMPLIFICATION
        $scope.data = data.amplification_data
        console.log $scope.data

      updateSeries = (buttons) ->
        buttons = buttons || $scope.wellButtons || {}
        $scope.chartConfig.series = []
        subtraction_type = if $scope.baseline_subtraction then 'baseline' else 'background'
        channel_count = if $scope.is_dual_channel then 2 else 1

        for ch_i in [1..channel_count] by 1
          for i in [0..15] by 1
            if buttons["well_#{i}"]?.selected
              $scope.chartConfig.series.push
                axis: 'y'
                dataset: "channel_#{ch_i}"
                key: "well_#{i}_#{subtraction_type}"
                label: if $scope.is_dual_channel then "channel_#{ch_i}, well_#{i}: " else "well_#{i}: "
                color: buttons["well_#{i}"].color

      $scope.$watchCollection 'wellButtons', updateSeries

      moveData = ->
        return if !angular.isNumber($scope.ampli_zoom) or !AMPLI_DATA_CACHE or !$scope.maxCycle
        num_cycle_to_show = $scope.maxCycle - $scope.ampli_zoom
        wRatio = num_cycle_to_show / $scope.maxCycle
        scrollbar_width = $('#ampli-scrollbar').width()
        $('#ampli-scrollbar .scrollbar').css(width: (scrollbar_width * wRatio) + 'px')

        $scope.amplification_data = helper.moveData AMPLI_DATA_CACHE.amplification_data, num_cycle_to_show, $scope.ampli_scroll, $scope.maxCycle
        updateChartData($scope.amplification_data)

      $scope.$watch 'ampli_zoom', (zoom) ->
        if AMPLI_DATA_CACHE?.amplification_data
          moveData()
          updateDragScrollWidth()
          $rootScope.$broadcast 'scrollbar:width:changed'

      $scope.$watch 'ampli_scroll', (val) ->
        moveData()

      $scope.$watch 'baseline_subtraction', (val) ->
        moveData()
        updateSeries()


]
