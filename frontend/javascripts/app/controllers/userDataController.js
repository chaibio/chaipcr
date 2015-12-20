window.ChaiBioTech.ngApp.controller('userDataController', [
  '$scope',
  '$stateParams',
  'User',
  function($scope, $stateParams, userService) {
    //$scope.name = "john";
    $scope.id = $stateParams.id - 1;
    $scope.userData = {};

    $scope.getUserData = function() {
      console.log($scope.id, "good work");
      userService.findUSer($scope.id).
        then(function(data) {
          //console.log(data);
          $scope.userData = data[$scope.id].user; // There is some error on bringing the individual user.
        });
    };




    $scope.getUserData();
  }
]);
