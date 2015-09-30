window.ChaiBioTech.ngApp.controller 'AmplificationChartCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  'AmplificationChartHelper'
  'Status'
  ($scope, $stateParams, Experiment, helper, Status) ->

    Status.startSync()
    $scope.$on 'destroy', ->
      Status.stopSync()

    $scope.$watch ->
      Status.getData()
    , (data, oldData) ->
      newStage = data?.experimentController?.expriment?.stage?.number
      oldStage = oldData?.experimentController?.expriment?.stage?.number
      state = data?.experimentController?.machine?.state

      if (parseInt(data?.experimentController?.expriment?.id) is parseInt($stateParams.id) and data?.optics?.collectData and newStage isnt oldStage) or
      (state is 'Idle' and $scope.experiment?.completion_status) or
      (state is 'Running' and parseInt(newStage) > 1 and oldStage isnt newStage)
        updateFluorescenceData()

    $scope.chartConfig = helper.chartConfig()

    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      $scope.experiment = data.experiment

    updateFluorescenceData = ->
      Experiment.getFluorescenceData($stateParams.id)
      .success (data) ->
        $scope.chartConfig.axes.x.max = data.total_cycles
        $scope.data = helper.neutralizeData data.fluorescence_data

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
