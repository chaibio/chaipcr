window.ChaiBioTech.ngApp.directive('escapeMenu', [
  '$rootScope',
  function($rootScope) {
    return {
      restrict: 'A',
      link: function($scope, elem) {

        $scope.registerEscape = false;

        if(! $scope.registerEscape) {
          $scope.registerEscape = angular.element(window).on('keyup', function(evt) {
            console.log("it works !!!!!");
            if(evt.keyCode === 27 && $scope.sideMenuOpen) {
              $rootScope.$broadcast('sidemenu:toggle');
              $scope.$apply();
            }
          });
        }

      }
    };
  }
]);
