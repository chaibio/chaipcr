window.ChaiBioTech.ngApp.controller('newUserController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  '$uibModal',
  function($scope, $stateParams, userService, $state, $uibModal) {

    $scope.id = $stateParams.id;
    $scope.userData = {};
    $scope.resetPassStatus = true;
    $scope.userData.password = "";
    $scope.userData.password_confirmation = "";

    $scope.update = function() { // This method actually saves and create a new user
      $scope.resetPassStatus = false;
      var format = $scope.userData;
      userService.save(format).then(function(data) {
        $state.transitionTo('settings.usermanagement', {}, { reload: true });
      });
    };


  }
]);
