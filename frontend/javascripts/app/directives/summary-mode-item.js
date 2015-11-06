window.ChaiBioTech.ngApp.directive('summaryModeItem', [
  'ExperimentLoader',
  function(ExperimentLoader) {

    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        reading: '@'
      },

      templateUrl: 'app/views/directives/summary-mode-item.html',

      link: function(scope, elem, attr) {
        scope.delta = true;
        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {
            //scope.shown = scope.hidden = scope.$parent.timeFormating(scope.reading);
          }
        });

      }
    };
  }
]);
