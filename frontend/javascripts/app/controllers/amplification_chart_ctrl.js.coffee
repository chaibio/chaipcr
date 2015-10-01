window.ChaiBioTech.ngApp.controller 'AmplificationChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  'AmplificationChartHelper'
  'Status'
  ($scope, $stateParams, Experiment, helper, Status) ->

    hasData = false
    $scope.data = [helper.paddData()]
    $scope.chartConfig = helper.chartConfig()

    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      $scope.experiment = data.experiment
      $scope.chartConfig.axes.x.ticks = helper.Xticks helper.getMaxExperimentCycle data.experiment
      return

    Status.startSync()
    $scope.$on 'destroy', ->
      Status.stopSync()

    $scope.$watch ->
      Status.getData()
    , (data, oldData) ->
      newStep = parseInt(data?.experimentController?.expriment?.step?.number) || null
      oldStep = parseInt(oldData?.experimentController?.expriment?.step?.number) || null
      state = data?.experimentController?.machine?.state
      isCurrentExp = parseInt(data?.experimentController?.expriment?.id) is parseInt($stateParams.id)

      if (state is 'Idle' and $scope.experiment?.completed_at and !hasData) or
      (state is 'Running' and (oldStep isnt newStep or !oldStep) and data.optics.collectData)
        updateFluorescenceData()

    updateFluorescenceData = ->
      Experiment.getFluorescenceData($stateParams.id)
      .success (data) ->
        $scope.chartConfig.axes.x.ticks = helper.Xticks data.total_cycles
        $scope.chartConfig.axes.y.max = helper.getMaxCalibration data.fluorescence_data
        $scope.data = helper.neutralizeData data.fluorescence_data
        console.log $scope.chartConfig
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
