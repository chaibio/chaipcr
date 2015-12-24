window.ChaiBioTech.ngApp.controller('newUserController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  '$uibModal',
  function($scope, $stateParams, userService, $state, $uibModal) {

    $scope.id = $stateParams.id;
    $scope.userData = {
      'name': "",
      'email': "",
      'password': "",
      'password_confirmation': ""
    };

    $scope.resetPassStatus = true;
    $scope.isAdmin = false;
    $scope.allowEditPassword = $scope.allowButtons = true;

    $scope.update = function() { // This method actually saves and create a new user
      console.log("bingo123", $scope.userData);
      $scope.resetPassStatus = false;
      var format = $scope.userData;
      userService.save(format).then(function(data) {
        $state.transitionTo('settings.usermanagement', {}, { reload: true });
      });
    };

    $scope.currentLogin = function() {
      userService.findUSer("current").
        then(function(data) {
          if(data.user.role === "admin") {
            $scope.isAdmin = true;
          }
        });
    };

    $scope.currentLogin();
  }
]);
