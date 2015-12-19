window.ChaiBioTech.ngApp.controller('userDataController', [
  '$scope',
  '$stateParams',
  'User',
  function($scope, $stateParams, userService) {
    //$scope.name = "john";
    $scope.id = $stateParams.id - 1;

    $scope.getUserData = function() {
      userService.fetch().
        then(function(data) {
          $scope.userData = data[$scope.id].user;
        });
    }

    $scope.getUserData();
  }
]);
