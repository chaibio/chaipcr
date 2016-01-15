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
            scope.image = scope.image + '-hover';
          } else {
            scope.image = scope.originalImage;
          }
        });

      }
    };
  }
]);
