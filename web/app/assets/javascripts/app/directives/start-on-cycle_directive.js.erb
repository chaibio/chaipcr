window.ChaiBioTech.ngApp.directive('startOnCycle', [
  'ExperimentLoader',
  '$timeout',
  'alerts',
  
  function(ExperimentLoader, $timeout, alerts) {
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
      templateUrl: 'app/views/directives/edit-value.html',

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

            if(scope.hidden <= Number(scope.$parent.stage.num_cycles)) {

              scope.reading = scope.hidden;
              $timeout(function() {
                ExperimentLoader.changeStartOnCycle(scope.$parent).then(function(data) {
                  console.log(data);
                });
              });
            } else {
              scope.hidden = scope.shown;
              var warningMessage = alerts.startOnCycleWarning;
              scope.$parent.showMessage(warningMessage);
            }
          } else {
            scope.hidden = scope.shown;
          }

          /*scope.edit = false;
          if(scope.reading <= scope.$parent.stage.num_cycles) {
            ExperimentLoader.changeStartOnCycle(scope.$parent);
          }*/

        };
      }
    };
  }
]);
