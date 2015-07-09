window.ChaiBioTech.ngApp.directive('startOnCycle', [
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
      templateUrl: 'app/views/directives/edit-value.html',

      link: function(scope, elem, attr) {

        scope.edit = false;

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
          if(scope.reading <= scope.$parent.stage.num_cycles) {
            ExperimentLoader.changeStartOnCycle(scope.$parent);
          }

        };
      }
    };
  }
]);
