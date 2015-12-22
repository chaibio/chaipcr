window.ChaiBioTech.ngApp.controller('userDataController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  '$uibModal',
  function($scope, $stateParams, userService, $state, $uibModal) {
    //$scope.name = "john";
    $scope.id = $stateParams.id;
    $scope.userData = {};
    $scope.resetPassStatus = false;
    $scope.userData.password = "";
    $scope.userData.password_confirmation = "";

    $scope.getUserData = function() {
      //console.log($scope, "good work");
      userService.findUSer($scope.id).
        then(function(data) {
          //console.log(data);
          data.some(function(userData, index) {
            if(userData.user.id == $scope.id) {
              $scope.userData = userData.user;
              return true;
            }
            return false;
          });
           // There is some error on bringing the individual user.
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

    $scope.update = function() {
      $scope.resetPassStatus = false;
      var format = $scope.userData;
      userService.updateUser($scope.id, format).then(function(data) {
        $state.transitionTo('settings.usermanagement', {}, { reload: true });
      });
    };

    $scope.deleteMessage = function() {
      $scope.uiModal = $uibModal.open({
        templateUrl: 'app/views/settings/delete-user.html',
        scope: $scope, //passed current scope to the modal
      });
    };

    $scope.getUserData();
  }
]);
