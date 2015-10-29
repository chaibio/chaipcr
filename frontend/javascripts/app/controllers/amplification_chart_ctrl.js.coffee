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
    $scope.data = [helper.paddData()]

    $scope.$on 'expName:Updated', ->
      $scope.experiment?.name = expName.name

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
      newStep = parseInt(data?.experimentController?.expriment?.step?.number) || null
      oldStep = parseInt(oldData?.experimentController?.expriment?.step?.number) || null
      state = data?.experimentController?.machine?.state
      oldState = oldData?.experimentController?.machine?.state
      isCurrentExp = parseInt(data?.experimentController?.expriment?.id) is parseInt($stateParams.id)

      if ((state is 'Idle' and $scope.experiment?.completed_at and !hasData) or
      (state is 'Idle' and oldState isnt state) or
      (state is 'Running' and (oldStep isnt newStep or !oldStep) and data.optics.collectData)) and
      $scope.RunExperimentCtrl.chart is 'amplification'
        updateFluorescenceData()

    $scope.$watch ->
      $scope.RunExperimentCtrl.chart
    , (val) ->
      if val is 'amplification'
        updateFluorescenceData()

    updateFluorescenceData = ->
      if !fetching
        fetching = true
        Experiment.getFluorescenceData($stateParams.id)
        .success (data) ->
          return if !data.fluorescence_data
          fetching = false
          $scope.chartConfig.axes.x.max = data.total_cycles
          $scope.chartConfig.axes.x.ticks = helper.Xticks data.total_cycles
          $scope.chartConfig.axes.y.max = helper.getMaxCalibration data.fluorescence_data
          $scope.data = helper.neutralizeData data.fluorescence_data
          hasData = true

    $scope.$watch 'wellButtons', (buttons) ->
      buttons = buttons || {}
      $scope.chartConfig.series = []

      for i in [0..15] by 1
        if buttons["well_#{i}"]?.selected
          $scope.chartConfig.series.push
            y: "well_#{i}"
            color: buttons["well_#{i}"].color
            thickness: '3px'
]
