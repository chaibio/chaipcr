window.ChaiBioTech.ngApp.directive('chartType', [
  function() {
    return {
      restric: 'EA',
      replace: true,
      scope: {
        name: '@name',
        image: '@image',
        second: '@second',
        callChart: '@callChart',
        type: '@type',
        current: '@current',
      },

      templateUrl: 'app/views/directives/chart-type.html',

      link: function(scope, attr, elem) {
        scope.hover = '';
        scope.originalImage = scope.image;

        scope.$watch('hover', function(newVal, oldVal) {

          if(newVal == 'hover') {
            scope.image = scope.originalImage + '-hover';
          } else {
            scope.selectedCheck(scope.current);
          }
        });

        scope.$watch('current', function(newVal) {
          scope.selectedCheck(newVal);
        });

        scope.selectedCheck = function(newVal) {
          if(newVal == scope.type) {
            scope.image = scope.originalImage + '-selected';
          } else {
            scope.image = scope.originalImage;
          }
        };
      }
    };
  }
]);
