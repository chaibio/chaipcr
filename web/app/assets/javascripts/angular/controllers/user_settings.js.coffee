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

    fetchUsers = ->
      User.fetch().then (users) ->
        $scope.users = users

    fetchUsers()

    $scope.user = {}

    $scope.addUser = ->
      $scope.user.role = if $scope.user.role then 'admin' else 'default'
      User.save($scope.user).then ->
        fetchUsers()
        $scope.modal.close()

    $scope.removeUser = (id) ->
      if $window.confirm 'Are you sure?'
        User.remove(id).then fetchUsers

    $scope.openAddUserModal = ->
      $scope.modal = $modal.open
        scope: $scope
        templateUrl: 'angular/views/user/modal-add-user.html'

]