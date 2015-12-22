window.ChaiBioTech.ngApp.controller('userDataController', [
  '$scope',
  '$stateParams',
  'User',
  function($scope, $stateParams, userService) {
    //$scope.name = "john";
    $scope.id = $stateParams.id - 1;
    $scope.userData = {};
    $scope.resetPassStatus = false;

    $scope.getUserData = function() {
      console.log($scope.id, "good work");
      userService.findUSer($scope.id).
        then(function(data) {
          console.log(data);
          $scope.userData = data[$scope.id].user; // There is some error on bringing the individual user.
        });
    };

    $scope.resetPass = function() {
      console.log("clicked");
      $scope.resetPassStatus = true;
    };

    $scope.update = function() {
      $scope.resetPassStatus = false;
      userService.save($scope.userData).then(function(data) {
        console.log(data);
      });
    };

    $scope.getUserData();
  }
]);
