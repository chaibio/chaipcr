window.ChaiBioTech.ngApp.directive('capsule', [
  'ExperimentLoader',
  '$timeout',
  function(ExperimentLoader, $timeout) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/capsule.html',

      scope: {
        value: "="
      },

      link: function(scope, elem, attr) {

        scope.$on("dataLoaded", function() {
          console.log(scope);
        });

      }
    }
  }
]);
