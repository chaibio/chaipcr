window.ChaiBioTech.ngApp
.controller 'UserSettingsCtrl', [
  '$scope'
  '$window'
  '$modal'
  'User'
  ($scope, $window, $modal, User) ->

    $scope.settings =
      option: 'A'
      checkbox: true

    $scope.goHome = ->
      $window.location = '#home'

    $scope.user = {}

    $scope.addUser = ->
      User.save($scope.user).then (resp) ->
        console.log resp

    $scope.openAddUserModal = ->
      $scope.modal = $modal.open
        scope: $scope
        templateUrl: 'angular/views/user/modal-add-user.html'

]