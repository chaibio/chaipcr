window.ChaiBioTech.ngApp
.controller 'UserSettingsCtrl', [
  '$scope'
  '$window'
  '$modal'
  ($scope, $window, $modal) ->

    $scope.settings =
      option: 'A'
      checkbox: true

    $scope.goHome = ->
      $window.location = '#home'

    $scope.openAddUserModal = ->
      $modal.open
        scope: $scope
        templateUrl: 'angular/views/user/modal-add-user.html'

]