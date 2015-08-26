window.ChaiBioTech.ngApp.directive('temp', [
  'ExperimentLoader',
  '$timeout',
  function(ExperimentLoader, $timeout) {
    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        unit: "@",
        reading: '=',
        delta: '=',
        action: '&' // Learn how to pass value in this scenario
      },
      templateUrl: 'app/views/directives/temp-time.html',
      transclude: true,

      link: function(scope, elem, attr) {

        scope.edit = false;

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {

            scope.shown = Number(scope.reading);
            scope.hidden = Number(scope.reading);
          }
        });

        scope.editAndFocus = function(className) {

          if(scope.delta) {
            scope.edit = ! scope.edit;
            $timeout(function() {
              $('.' + className).focus();
            });
          }
        };

        scope.save = function() {

          scope.edit = false;
          if(! isNaN(scope.hidden)) {

            scope.reading = scope.hidden;
            $timeout(function() {
              ExperimentLoader.changeDeltaTemperature(scope.$parent).then(function(data) {
                console.log(data);
              });
            });

          } else {
            scope.shown = scope.hidden = scope.reading;
          }
        };

      }
    };
  }
]);
