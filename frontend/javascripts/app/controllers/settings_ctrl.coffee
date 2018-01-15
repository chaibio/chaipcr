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
window.App.controller 'SettingsCtrl', [
  '$scope'
  'User'
  'Device'
  ($scope, User, Device) ->

    $scope.isBeta = true
    $scope.anotherExperimentInProgress = false
    $scope.checked = false

    $scope.$on 'status:data:updated', (e, data, oldData) ->
      return if !data
      return if !data.experiment_controller
      $scope.state = data.experiment_controller.machine.state
      if $scope.state isnt 'idle'
        $scope.anotherExperimentInProgress = true
      else
        $scope.anotherExperimentInProgress = false

    Device.getVersion(true).then (resp) ->
      $scope.has_serial_number = resp.serial_number

    User.getCurrent().then (resp) ->
      $scope.user = resp.data.user

    Device.getVersion().then (data) ->
      console.log data
      if data.software_release_variant == "beta"
        $scope.isBeta = true

    Device.isDualChannel()
    .then (resp) ->
      $scope.checked = true
      $scope.is_dual_channel = resp

    backdrop = $('.maintainance-backdrop')
    backdrop.css('height', $('.wizards-container').height())
]
