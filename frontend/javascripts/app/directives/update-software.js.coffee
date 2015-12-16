window.App.directive 'updateSoftware', [
  'Device'
  '$modal'
  '$window'
  (Device, $modal, $window) ->

    restrict: 'EA'
    link: ($scope, elem) ->

      checkUpdateModal = null
      modalProgress = null

      elem.on 'click', (e) ->
        $scope.$apply ->
          $scope.checkForUpdate()

      $scope.updateSoftware = ->

        modalProgress = $modal.open
          templateUrl: 'app/views/directives/update-software/modal-update-in-progress.html'

        updatePromise = Device.updateSoftware()

        updatePromise.then (resp) ->
          modalProgress.dismiss()
          $window.location.reload()

        updatePromise.catch (err) ->
          modalProgress.dismiss()
          $modal.open
            templateUrl: 'app/views/directives/update-software/modal-update-error.html'

      $scope.checkForUpdate = ->
        Device.checkForUpdate().then (resp) ->
          $scope.update = resp.data
          # $scope.update = {'upgrade':{'version':'1.0.1','release_date':null,'brief_description':'this is the brief description','full_description':'this is the full description'}}

          if resp.data.upgrade
            checkUpdateModal = $modal.open
              templateUrl: 'app/views/directives/update-software/modal-update-available.html'
              scope: $scope
          else
            $modal.open
              templateUrl: 'app/views/directives/update-software/modal-no-updates.html'
]