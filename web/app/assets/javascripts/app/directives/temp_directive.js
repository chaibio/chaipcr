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
        action: '&' // Learn how to pass value in this scenario
      },
      templateUrl: 'app/views/directives/temp-time.html',
      //bindToController: true,
      transclude: true,

      controller: function() {
        this.wow = "hiya";
      },

      link: function(scope, elem, attr) {

        scope.edit = false;

        scope.editAndFocus = function(className) {
          scope.edit = ! scope.edit;
          $timeout(function() {
            $('.' + className).focus();
          })
        }
      }
    }
  }
]);
