window.ChaiBioTech.ngApp.controller('userDataController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  '$uibModal',
  function($scope, $stateParams, userService, $state, $uibModal) {

    $scope.id = $stateParams.id || 'current';
    $scope.userData = {};
    $scope.resetPassStatus = false;
    $scope.userData.password = "";
    $scope.userData.password_confirmation = "";

    $scope.getUserData = function() {
      if(isNaN($scope.id)) {
        //userService.curr
      }
      userService.findUSer($scope.id).
        then(function(data) {
          $scope.id = data.user.id;
          $scope.userData = data.user;
        });
    };

    $scope.resetPass = function() {

      $scope.userData.password = "";
      $scope.userData.password_confirmation = "";
      $scope.resetPassStatus = true;
    };

    $scope.deleteUser = function() {

      userService.remove($scope.id).then(function(data) {
        $state.go('settings.usermanagement', {}, { reload: true });
      });
    };

    $scope.update = function(from) {
      $scope.resetPassStatus = false;
      var format = {'user': $scope.userData};
      userService.updateUser($scope.id, format).then(function(data) {
        if($state.is("settings.current-user")) {
          $state.transitionTo('settings.root', {}, { reload: true });
        } else {
          $state.transitionTo('settings.usermanagement', {}, { reload: true });
        }

      });
    };

    $scope.deleteMessage = function() {
      $scope.uiModal = $uibModal.open({
        templateUrl: 'app/views/settings/delete-user.html',
        scope: $scope,
      });
    };

    $scope.getUserData();
  }
]);
