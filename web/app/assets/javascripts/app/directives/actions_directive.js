window.ChaiBioTech.ngApp.directive('actions', [
  'ExperimentLoader',
  '$timeout',
  'canvas',
  function(ExperimentLoader, $timeout, canvas) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/actions.html',

      link: function(scope, elem, attr) {
        scope.actionPopup = false;

        scope.addStep = function() {
          ExperimentLoader.addStep(scope)
            .then(function(data) {
              console.log(data);
              //scope.reloadAll();
              //Now create a new step and insert it...!
              scope.fabricStep.parentStage.addNewStep(data);
            });
        };

        scope.deleteStep = function() {
          ExperimentLoader.deleteStep(scope)
            .then(function(data) {
              console.log("deleted");
            });
        };

        scope.addStage = function(type) {
          ExperimentLoader.addStage(scope, type)
            .then(function(data) {
              console.log("stage added", data);
            });
        };

      }
    };
  }
]);
