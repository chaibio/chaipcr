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

        scope.$on("dataLoaded", function() {

          scope.$watch('step.pause', function(pauseState) {
            if(pauseState) {
              scope.pauseAction = "REMOVE";
            } else {
              scope.pauseAction = "ADD A";
            }
          })
        });

        scope.addStep = function() {
          ExperimentLoader.addStep(scope)
            .then(function(data) {
              console.log(data);
              //Now create a new step and insert it...!
              scope.fabricStep.parentStage.addNewStep(data, scope.fabricStep);
            });
        };

        scope.deleteStep = function() {
          ExperimentLoader.deleteStep(scope)
            .then(function(data) {
              console.log("deleted", data);
              scope.fabricStep.parentStage.deleteStep(data, scope.fabricStep);
            });
        };

        scope.addStage = function(type) {
          ExperimentLoader.addStage(scope, type)
            .then(function(data) {
              console.log("added", data);
              scope.actionPopup = false;
              scope.fabricStep.parentStage.parent.addNewStage(data, scope.fabricStep.parentStage);
            });
        };

        scope.addPause = function() {
          scope.step.pause = ! scope.step.pause;
          ExperimentLoader.changePause(scope)
          .then(function(data) {
            console.log("added", data);
          });
        }

      }
    };
  }
]);
