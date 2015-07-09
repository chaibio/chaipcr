window.ChaiBioTech.ngApp.directive('holdDuration', [
  'ExperimentLoader',
  '$timeout',
  function(ExperimentLoader, $timeout) {
    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        unit: "@",
        reading: '='
      },
      templateUrl: 'app/views/directives/edit-value.html',

      link: function(scope, elem, attr) {

        scope.edit = false;
        scope.delta = true; // This is to prevent the directive become disabled, check delta in template, this is used for auto delta field
        scope.editAndFocus = function(className) {
          scope.edit = ! scope.edit;
          $timeout(function() {
            $('.' + className).focus();
          });
        };

        scope.save = function() {

          scope.edit = false;
          ExperimentLoader.changeHoldDuration(scope.$parent);
        }
      }
    };
  }
]);
