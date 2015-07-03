window.ChaiBioTech.ngApp.directive('time', [
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

      controller: function() {

      },

      transclude: true,

      templateUrl: 'app/views/directives/temp-time.html',

      //bindToController: true,

      link: function(scope, elem, attr) {

        scope.edit = false;

        scope.editAndFocus = function(className) {
          scope.edit = ! scope.edit;
          $timeout(function() {
            $('.' + className).focus();
          });
        };
      }
    };
  }
]);
