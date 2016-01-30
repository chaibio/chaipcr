window.ChaiBioTech.ngApp.directive('deleteMode', [
  function() {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/delete-mode.html',
      scope: {
        'deleteMode': '=mode',
        'deleteExp': '&',
        'experiment': '@experiment'
      },

      link: function(scope, elem, attr) {
        scope.deleteClicked = false;

        scope.$watch('deleteMode', function(newVal, oldVal) {
          if(newVal === false && scope.deleteClicked) {
            scope.reset();
          }
        });

        scope.deleteClickedHandle = function() {

          scope.deleteClicked = !scope.deleteClicked;
          var left = angular.element(elem).position().left;

          if(scope.deleteClicked) {
            angular.element(elem).css("left", (left - 70) + "px");
          } else {
            angular.element(elem).css("left", (left + 70) + "px");
          }
        };

        scope.reset = function() {
          var left = angular.element(elem).position().left;
          angular.element(elem).css("left", (left + 70) + "px");
          scope.deleteClicked = false;
        };

        scope.tryDeletion = function() {
          console.log(scope.deleteExp(scope.experiment));
        };

      }
    };
  }
]);
