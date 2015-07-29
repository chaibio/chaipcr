window.ChaiBioTech.ngApp.directive('general', [
  'ExperimentLoader',
  '$timeout',
  function(ExperimentLoader, $timeout) {

    return {
      restric: 'EA',
      replace: false,
      scope: false,
      templateUrl: 'app/views/directives/general-info.html',

      link: function(scope, elem, attr) {


        scope.stepNameShow = false;
        scope.stageNoCycleShow = false;
        scope.popUp = false;
        scope.showCycling = false;

        scope.$on("dataLoaded", function() {
          // there is a slight delay for the controller to catch up so wait for it and load
          scope.delta_state = (scope.stage.auto_delta) ? "ON" : "OFF";

          scope.$watch('stage.auto_delta', function(newVal, oldVal) {
            scope.delta_state = (scope.stage.auto_delta) ? "ON" : "OFF";
          });

          scope.$watch('step.collect_data', function(newVal, oldVal) {
            scope.gather_data_state = (scope.step.collect_data || scope.step.ramp.collect_data) ? "ON" : "OFF";
          });

          scope.$watch('step.ramp.collect_data', function(newVal, oldVal) {
            scope.gather_data_state = (scope.step.collect_data || scope.step.ramp.collect_data) ? "ON" : "OFF";
          });

          scope.$watch('stage.stage_type', function(newVal, oldVal) {
            if(newVal === "cycling") {
              scope.showCycling = true;
            } else {
              scope.showCycling = false;
            }
          });

        });

        // focusElement is the classname of the desired input box to be shown
        scope.clickOnField = function(field, focusElement) {

          scope[field] = true;
          // It takes while after render to focus, thats y we have a $timeout
          $timeout(function() {
            $('.' + focusElement).focus();
          });
        };

        scope.saveCycle = function() {

          scope.stageNoCycleShow = false;
          if(scope.stage.num_cycles >= scope.stage.auto_delta_start_cycle) {
            ExperimentLoader.saveCycle(scope);
          } else {
            alert("Entar a value greater than" + scope.stage.auto_delta_start_cycle);
          }
        };

        scope.changeDelta = function() {

          if(scope.stage.stage_type === "cycling") {

            scope.stage.auto_delta = ! scope.stage.auto_delta;
            scope.delta_state = (scope.stage.auto_delta) ? "ON" : "OFF";
            ExperimentLoader.updateAutoDelata(scope).then(function() {
              console.log("Happy happy ---- Just testing ____-------______");
            });
          } else {
            alert("Plese select a cycling stage");
          }
        };

        scope.saveStepName = function() {

          scope.stepNameShow = false;
          ExperimentLoader.saveName(scope);
        };

        scope.changeDuringStep = function() {

          scope.popUp = ! scope.popUp;
          scope.step.collect_data = ! scope.step.collect_data;
          ExperimentLoader.gatherDuringStep(scope);
        };

        scope.changeDuringRamp = function() {

          scope.popUp = ! scope.popUp;
          scope.step.ramp.collect_data = ! scope.step.ramp.collect_data;
          ExperimentLoader.gatherDataDuringRamp(scope);
        };

      }
    };
  }
]);
