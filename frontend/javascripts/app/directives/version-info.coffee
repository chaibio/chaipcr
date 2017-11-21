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
window.App.directive 'versionInfo', [
  'Device'
  'Status'
  '$rootScope'
  (Device, Status, $rootScope) ->
    restrict: 'EA'
    replace: true
    scope:
      cache: '='
    templateUrl: 'app/views/directives/version-info.html'
    link: ($scope, elem, attrs) ->

      $scope.update_available = 'unavailable'

      $scope.$on 'status:data:updated', (e, data) ->
        status = data?.device?.update_available || 'unknown'
        if status isnt 'unknown'
          $scope.update_available = status
        #if data.device.update_available is 'unknown' && data.device.update_error
          #if $scope.checkedUpdate
            #$scope.openUpdateModal()
          #$scope.update_available = 'unavailable'
          #$scope.checkedUpdate = false

      Device.getVersion(true).then (resp) ->
        $scope.data = resp

      $scope.updateSoftware = ->
        Device.updateSoftware()

      $scope.openUpdateModal = ->
        Device.openUpdateModal()

      $scope.checkForUpdates = ->
        $scope.checking_update = true

        checkPromise = Device.checkForUpdate()
        checkPromise.then (is_available) ->
          $scope.update_available = is_available
          $scope.checkedUpdate = true
          if is_available is 'available'
            $scope.openUpdateModal()

        checkPromise.catch ->
          alert 'Error while checking update!'
          $scope.update_available = 'unavailable'
          $scope.checkedUpdate = false

        checkPromise.finally ->
          $scope.checking_update = false

]
