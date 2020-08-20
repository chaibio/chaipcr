
window.ChaiBioTech.ngApp.directive('exportClick', [
  '$rootScope',
  function($rootScope) {
    return {
      restrict: 'A',
      require: '^updatePanel',
      link: function($scope, elem, attrs, ctrl) {
        if(! $scope.registerEscape) {
          $scope.registerEscape = angular.element('body').click(function(evt) {
            if($scope.export_status === 'done') {
              $scope.setReadyExportButton();
            }
          });
        }
      }
    };
  }
]);
