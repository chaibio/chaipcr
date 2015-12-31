window.ChaiBioTech.ngApp.controller('newUserController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  '$uibModal',
  'userFormErrors',
  function($scope, $stateParams, userService, $state, $uibModal, userFormErrors) {

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
    $scope.passError = false;
    $scope.passLengthError = false;
    $scope.emailAlreadtTaken = false;

    $scope.update = function(form) { // This method actually saves and create a new user
      //console.log("bingo123", $scope.userData);
      if(form.$valid && ! $scope.passError) {
        var format = $scope.userData;
        userService.save(format).then(function(data) {
          $scope.resetPassStatus = false;
          $state.transitionTo('settings.usermanagement', {}, { reload: true });
        }, function(err) {
          console.log("there is some issue", err, userFormErrors);
          var problem = err.user;
          userFormErrors.handleError($scope, problem);
        });
      }
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
