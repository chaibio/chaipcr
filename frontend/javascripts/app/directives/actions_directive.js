window.ChaiBioTech.ngApp.directive('actions', [
  'ExperimentLoader',
  '$timeout',
  'canvas',
  'popupStatus',

  function(ExperimentLoader, $timeout, canvas, popupStatus) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/actions.html',

      link: function(scope, elem, attr) {

        scope.actionPopup = false;
        scope.infiniteHoldStep = false;
        scope.infiniteHoldStage = false;
        scope.editStageMode = false;
        scope.editStageText = "EDIT STAGE";

        scope.$on("dataLoaded", function() {

          scope.$watch("actionPopup", function(newVal) {
            popupStatus.popupStatusAddStage = scope.actionPopup;
          });

          scope.$watch('step.pause', function(pauseState) {
            if(pauseState) {
              scope.pauseAction = "REMOVE";
            } else {
              scope.pauseAction = "ADD A";
            }
          });

          scope.$watch("step.id", function(newVal) {

            if(scope.fabricStep) {

              if(scope.fabricStep.circle.holdTime.text === "∞") {
                scope.infiniteHoldStep = scope.infiniteHoldStage = true;
                return true;
              }
              scope.infiniteHoldStep = false;

              if(scope.containInfiniteStep(scope.fabricStep.parentStage)) {
                scope.infiniteHoldStage = true;
                return true;
              }

              scope.infiniteHoldStage = false;
            }
          });

        });

        scope.containInfiniteStep = function(stage) {

          var lastStep = stage.childSteps[stage.childSteps.length - 1];
          if(lastStep.circle.holdTime.text === "∞") {
            return true;
          }
          return false;
        };

        scope.addStep = function() {

          if(! scope.infiniteHold) {
            ExperimentLoader.addStep(scope)
              .then(function(data) {
                console.log(data);
                //Now create a new step and insert it...!
                scope.fabricStep.parentStage.addNewStep(data, scope.fabricStep);
              });
          }

        };

        scope.deleteStep = function() {

          ExperimentLoader.deleteStep(scope)
            .then(function(data) {
              console.log("deleted", data);
              scope.fabricStep.parentStage.deleteStep(data, scope.fabricStep);
            });
        };


        scope.editStage = function() {

          scope.editStageMode = ! scope.editStageMode;
          scope.editStageText = (scope.editStageMode) ? "DONE" : "EDIT STAGE";
          canvas.editStageMode(scope.editStageMode);
        };

        scope.addPause = function() {

          scope.step.pause = ! scope.step.pause;
          ExperimentLoader.changePause(scope)
          .then(function(data) {
            console.log("added", data);
          });
        };

      }
    };
  }
]);
