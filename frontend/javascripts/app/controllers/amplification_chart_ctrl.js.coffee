window.ChaiBioTech.ngApp.controller 'AmplificationChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  'AmplificationChartHelper'
  'Status'
  'expName'
  '$rootScope'
  ($scope, $stateParams, Experiment, helper, Status, expName, $rootScope) ->

    hasData = false
    fetching = false
    $scope.chartConfig = helper.chartConfig()
    $scope.chartConfig.axes.x.ticks = helper.Xticks $stateParams.max_cycle || 1
    $scope.chartConfig.axes.x.max = $stateParams.max_cycle || 1
    $scope.data = [helper.paddData()]
    $scope.log_linear = 'log'
    $scope.COLORS = helper.COLORS
    $scope.fluorescence_data = null
    FLUORESCENCE_DATA_CACHE = null
    $scope.baseline_subtraction = true

    $scope.$on 'expName:Updated', ->
      $scope.experiment?.name = expName.name

    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      maxCycle = helper.getMaxExperimentCycle data.experiment
      $scope.maxCycle = maxCycle
      $scope.chartConfig.axes.x.ticks = helper.Xticks maxCycle
      $scope.chartConfig.axes.x.max = maxCycle
      $scope.experiment = data.experiment
      return

    Status.startSync()
    $scope.$on '$destroy', ->
      Status.stopSync()

    $scope.$watch ->
      Status.getData()
    , (data, oldData) ->
      newStep = parseInt(data?.experiment_controller?.expriment?.step?.number) || null
      oldStep = parseInt(oldData?.experiment_controller?.expriment?.step?.number) || null
      state = data?.experiment_controller?.machine?.state
      oldState = oldData?.experiment_controller?.machine?.state
      isCurrentExp = parseInt(data?.experiment_controller?.expriment?.id) is parseInt($stateParams.id)

      if ((state is 'idle' and $scope.experiment?.completed_at and !hasData) or
      (state is 'idle' and oldState isnt state) or
      (state is 'running' and (oldStep isnt newStep or !oldStep) and data.optics.collect_data and oldData.optics.collect_data is 'true') )
        fetchFluorescenceData()

    $scope.$watch ->
      $scope.RunExperimentCtrl.chart
    , (val) ->
      if val is 'amplification'
        fetchFluorescenceData()

    fetchFluorescenceData = ->
      return if $scope.RunExperimentCtrl.chart isnt 'amplification'
      if !fetching
        fetching = true
        Experiment.getFluorescenceData($stateParams.id)
        .success (data) ->
          return if !data.fluorescence_data
          data.min_cycle = 1
          data.max_cycle = data.total_cycles
          FLUORESCENCE_DATA_CACHE = angular.copy data
          $scope.fluorescence_data = data
          updateChartData(data)
          updateButtonCts()
          hasData = true

        .finally ->
          fetching = false

    updateButtonCts = ->
      for ct, i in FLUORESCENCE_DATA_CACHE.ct
        $scope.wellButtons["well_#{i}"].ct = ct

    updateChartData = (data) ->
      return if !data
      $scope.chartConfig.axes.x.min = data.min_cycle
      $scope.chartConfig.axes.x.max = data.max_cycle
      $scope.chartConfig.axes.x.ticks = helper.Xticks data.min_cycle, data.max_cycle
      $scope.chartConfig.axes.y.max = helper.getMaxCalibration data.fluorescence_data
      neutralizedData = helper.neutralizeData data.fluorescence_data
      $scope.data = neutralizedData["#{if $scope.baseline_subtraction then 'baseline' else 'background'}"]


    $scope.$watch 'wellButtons', (buttons) ->
      buttons = buttons || {}
      $scope.chartConfig.series = []

      for i in [0..15] by 1
        if buttons["well_#{i}"]?.selected
          $scope.chartConfig.series.push
            y: "well_#{i}"
            color: buttons["well_#{i}"].color
            thickness: '3px'

    $scope.$watch 'baseline_subtraction', (val) ->
      updateChartData($scope.fluorescence_data)

    moveData = ->
      cycle_num = $scope.ampli_zoom
      return if !angular.isNumber(cycle_num) or !FLUORESCENCE_DATA_CACHE or !$scope.maxCycle
      num_cycle_to_show = $scope.maxCycle - cycle_num
      wRatio = num_cycle_to_show / $scope.maxCycle
      scrollbar_width = $('#ampli-scrollbar').css('width').replace 'px', ''
      $('#ampli-scrollbar .scrollbar').css(width: (scrollbar_width * wRatio) + 'px')
      $rootScope.$broadcast 'scrollbar:width:changed'

      $scope.fluorescence_data = helper.moveData FLUORESCENCE_DATA_CACHE.fluorescence_data, num_cycle_to_show, $scope.ampli_scroll, $scope.maxCycle
      updateChartData($scope.fluorescence_data)

    $scope.$watch 'ampli_zoom', moveData
    $scope.$watch 'ampli_scroll', moveData


]
