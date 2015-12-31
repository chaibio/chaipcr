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
    $scope.passError = false;
    $scope.passLengthError = false;
    $scope.emailAlreadtTaken = false;

    $scope.update = function() { // This method actually saves and create a new user
      //console.log("bingo123", $scope.userData);

      var format = $scope.userData;
      userService.save(format).then(function(data) {
        $scope.resetPassStatus = false;
        $state.transitionTo('settings.usermanagement', {}, { reload: true });
      }, function(err) {
        console.log("there is some issue", err);
        var problem = err.user;
        for(var errKey in problem.errors) {
          if(errKey === 'email') {
            //console.log("here is the problem");
            $scope.emailAlreadtTaken = true;
          } else if(errKey === 'password') {
            $scope.passLengthError = true;
          }
          break;
        }
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
