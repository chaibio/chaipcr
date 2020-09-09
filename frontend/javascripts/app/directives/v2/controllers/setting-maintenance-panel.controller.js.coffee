window.App.controller 'SettingMaintenancePanelCtrl', [
  '$scope'
  'User'
  '$state'
  'Device'
  ($scope, User, $state, Device) ->
    $scope.isBeta = true
    $scope.anotherExperimentInProgress = true
    $scope.checked = false
    $scope.performance_screen = false

    $scope.$on 'status:data:updated', (e, data, oldData) ->

      return if !data
      return if !data.experiment_controller
      $scope.state = data.experiment_controller.machine.state
      if $scope.state isnt 'idle'
        $scope.anotherExperimentInProgress = true
      else
        $scope.anotherExperimentInProgress = false

    Device.isDualChannel()
    .then (resp) ->
      $scope.checked = true
      $scope.is_dual_channel = resp

    Device.getVersion(true).then (resp) ->
      $scope.has_serial_number = resp.serial_number

    $scope.onPerformanceClick = () ->
      if $scope.anotherExperimentInProgress
        return
      $scope.$parent.$dismiss()
      $state.go('thermal_performance_diagnostic.init')  

    $scope.onOpticalClick = (is_dual) ->
      if $scope.anotherExperimentInProgress || !$scope.checked
        return
      $scope.$parent.$dismiss()
      if is_dual
        $state.go('optical_test_2ch.intro')
      else
        $state.go('optical_test_1ch.introduction')

    $scope.onUniformityClick = () ->
      if $scope.anotherExperimentInProgress
        return
      $scope.$parent.$dismiss()
      $state.go('thermal_consistency.introduction')

    $scope.onCalibOpticalClick = (is_dual) ->
      if $scope.anotherExperimentInProgress || !$scope.checked
        return
      $scope.$parent.$dismiss()
      if is_dual
        $state.go('2_channel_optical_cal.intro')
      else
        $state.go('optical_cal.intro')

    return
]
