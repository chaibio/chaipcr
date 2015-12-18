window.ChaiBioTech.ngApp.controller 'AmplificationChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  'AmplificationChartHelper'
  'Status'
  'expName'
  ($scope, $stateParams, Experiment, helper, Status, expName) ->

    hasData = false
    fetching = false
    $scope.chartConfig = helper.chartConfig()
    $scope.chartConfig.axes.x.ticks = helper.Xticks $stateParams.max_cycle || 1
    $scope.chartConfig.axes.x.max = $stateParams.max_cycle || 1
    $scope.data = [helper.paddData()]
    $scope.log_linear = 'log'
    $scope.COLORS = helper.COLORS
    $scope.fluorescence_data = null
    $scope.baseline_subtraction = true

    $scope.$on 'expName:Updated', ->
      $scope.experiment?.name = expName.name

    $scope.$on 

    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      maxCycle = helper.getMaxExperimentCycle data.experiment
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
        updateFluorescenceData()

    $scope.$watch ->
      $scope.RunExperimentCtrl.chart
    , (val) ->
      if val is 'amplification'
        updateFluorescenceData()

    updateFluorescenceData = ->
      return if $scope.RunExperimentCtrl.chart isnt 'amplification'
      if !fetching
        fetching = true
        Experiment.getFluorescenceData($stateParams.id)
        .success (data) ->
          return if !data.fluorescence_data
          $scope.fluorescence_data = data
          $scope.chartConfig.axes.x.max = $scope.fluorescence_data.total_cycles
          $scope.chartConfig.axes.x.ticks = helper.Xticks $scope.fluorescence_data.total_cycles
          $scope.chartConfig.axes.y.max = helper.getMaxCalibration $scope.fluorescence_data.fluorescence_data
          $scope.neutralizeData = helper.neutralizeData $scope.fluorescence_data.fluorescence_data, $scope.baseline_subtraction
          updateChartData()
          updateButtonCts()
          hasData = true

        .finally ->
          fetching = false

    updateButtonCts = ->
      for ct, i in $scope.fluorescence_data.ct
        $scope.wellButtons["well_#{i}"].ct = ct

    updateChartData = ->
      return if !$scope.neutralizeData
      $scope.data = $scope.neutralizeData["#{if $scope.baseline_subtraction then 'baseline' else 'background'}"]


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
      updateChartData()

]
