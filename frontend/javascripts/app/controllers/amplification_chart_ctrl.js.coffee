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
      console.log $scope.chartConfig
      $scope.data = [helper.paddData()]
      $scope.log_linear = 'log'
      $scope.COLORS = helper.COLORS
      $scope.amplification_data = null
      AMPLI_DATA_CACHE = null
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
        return if $scope.RunExperimentCtrl.chart isnt 'amplification'
        if !fetching
          fetching = true
          hasInit = true

          $timeout ->
            Experiment.getAmplificationData($stateParams.id)
            .success (data) ->
              hasData = true
              return if !data.amplification_data
              return if data.amplification_data.length is 0
              data.amplification_data.shift()
              data.ct.shift()
              AMPLI_DATA_CACHE = angular.copy data
              $scope.amplification_data = helper.neutralizeData(data.amplification_data, $scope.is_dual_channel)
              moveData()
              updateButtonCts()

            .finally ->
              fetching = false
          , 1500

      updateButtonCts = ->
        # channel_count = if $scope.is_dual_channel then 2 else 1
        # for well_i in [0..15] by 1
        #   $scope.wellButtons["well_#{well_i}"].ct = _.filter AMPLI_DATA_CACHE.ct, (ct) ->
        #     ct[1] is 

      updateDragScrollWidth = ->
        return if $scope.RunExperimentCtrl.chart isnt 'amplification'
        svg = drag_scroll.find('svg')
        return if svg.length is 0
        drag_scroll_width = svg.width() - svg.find('g.y-axis').first()[0].getBBox().width
        num_cycle_to_show = $scope.maxCycle - $scope.ampli_zoom
        width_per_cycle = drag_scroll_width/num_cycle_to_show
        w = width_per_cycle * $scope.maxCycle
        drag_scroll.attr 'width', Math.round w

      updateChartData = (data) ->
        return if !data
        $scope.chartConfig.axes.x.min = data.min_cycle
        $scope.chartConfig.axes.x.max = data.max_cycle
        $scope.chartConfig.axes.x.ticks = helper.Xticks data.min_cycle, data.max_cycle
        $scope.chartConfig.axes.y.max = helper.getMaxCalibration AMPLI_DATA_CACHE.amplification_data
        $scope.chartConfig.series = helper.chartSeries((if $scope.baseline_subtraction then 'baseline' else 'background'), $scope.is_dual_channel)
        console.log $scope.chartConfig
        $scope.data = data.amplification_data

        # $scope.data = neutralizedData["#{if $scope.baseline_subtraction then 'baseline' else 'background'}"]


      # $scope.$watchCollection 'wellButtons', (buttons) ->
      #   buttons = buttons || {}
      #   $scope.chartConfig.series = []

      #   for i in [0..15] by 1
      #     if buttons["well_#{i}"]?.selected
      #       $scope.chartConfig.series.push
      #         y: "well_#{i}"
      #         color: buttons["well_#{i}"].color
      #         thickness: '3px'

      $scope.$watch 'baseline_subtraction', (val) ->
        updateChartData($scope.amplification_data)

      moveData = ->
        return if !angular.isNumber($scope.ampli_zoom) or !AMPLI_DATA_CACHE or !$scope.maxCycle
        num_cycle_to_show = $scope.maxCycle - $scope.ampli_zoom
        wRatio = num_cycle_to_show / $scope.maxCycle
        scrollbar_width = $('#ampli-scrollbar').width()
        $('#ampli-scrollbar .scrollbar').css(width: (scrollbar_width * wRatio) + 'px')

        new_data = helper.moveData $scope.amplification_data, num_cycle_to_show, $scope.ampli_scroll, $scope.maxCycle
        updateChartData(new_data)

      $scope.$watch 'ampli_zoom', (zoom) ->
        if AMPLI_DATA_CACHE?.amplification_data
          moveData()
          updateDragScrollWidth()
          $rootScope.$broadcast 'scrollbar:width:changed'

      $scope.$watch 'ampli_scroll', (val) ->
        moveData()


]
