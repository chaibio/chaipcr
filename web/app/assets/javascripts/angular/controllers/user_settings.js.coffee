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

    fetchUsers = ->
      User.fetch().then (users) ->
        $scope.users = users

    fetchUsers()

    $scope.goHome = ->
      $window.location = '#home'

    $scope.user = {}

    $scope.addUser = ->
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