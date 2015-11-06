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
        scope.date = false;
        scope.$watch("reading", function(val) {
          scope.data = scope.reading;

          if(angular.isDefined(scope.reading)) {
            if(scope.caption === "Created on") {
              scope.date = true;
              scope.data = (scope.reading).replace("T", ",").slice(0, -8);
            }
          }

        });

      }
    };
  }
]);
