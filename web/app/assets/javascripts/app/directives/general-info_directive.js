window.ChaiBioTech.ngApp.directive('general', [
  'ExperimentLoader',
  '$timeout',
  '$modal',
  function(ExperimentLoader, $timeout, $modal) {

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
        scope.warningMessage = "You have entered a wrong value. Please make sure you enter digits.";

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
              scope.cycleNoBackup = scope.stage.num_cycles;
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
            scope.cycleNoBackup = scope.stage.num_cycles;
          } else {
            var warningMessage = "The value you have entered is less than AUTO DELTA START CYCLE. Please enter a value greater than " + scope.stage.auto_delta_start_cycle +" or reduce AUTO DELTA START CYCLE and re-enter value.";
            scope.showMessage(warningMessage);
            scope.stage.num_cycles = scope.cycleNoBackup;
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
            var warningMessage = "You can,t turn on auto delta on this stage. Please select a CYCLING STAGE to enable auto delat.";
            scope.showMessage(warningMessage);
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
