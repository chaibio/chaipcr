window.ChaiBioTech.ngApp.directive('temperature', [
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
        action: '&' // Learn how to pass value in this scenario
      },

      templateUrl: 'app/views/directives/edit-value.html',

      link: function(scope, elem, attr) {

        scope.edit = false;

        scope.editAndFocus = function(className) {

          scope.edit = ! scope.edit;
          $timeout(function() {
            $('.' + className).focus();
          });
        };

        scope.save = function() {

          scope.edit = false;
          ExperimentLoader.changeTemperature(scope.$parent);
        };
      }
    };
  }
]);
