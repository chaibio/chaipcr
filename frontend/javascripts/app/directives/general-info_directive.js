window.ChaiBioTech.ngApp.directive('general', [
  'ExperimentLoader',
  '$timeout',
  '$modal',
  'alerts',
  'popupStatus',

  function(ExperimentLoader, $timeout, $modal, alerts, popupStatus) {

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
        scope.warningMessage = alerts.nonDigit;
        var onClickValue;


        scope.$on("dataLoaded", function() {
          // there is a slight delay for the controller to catch up so wait for it and load
          scope.delta_state = (scope.stage.auto_delta) ? "ON" : "OFF";

          scope.$watch('popUp', function(newVal) {
            popupStatus.popupStatusGatherData = scope.popUp;
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

          //console.log($('.edit-step-name').val(), focusElement);
          scope[field] = true;
          onClickValue = $('.' + focusElement).val();

          $('.' + focusElement).width($('.' + focusElement).parent().width()); // Set the width of the text field;
          if($('.' + focusElement).parent().width() < 30) {
            $('.' + focusElement).width(30);
          }

          console.log($('.' + focusElement).parent().width());
          if($('.' + focusElement).val() === "") {
            onClickValue = null;
          }
          // It takes while after render to focus, thats y we have a $timeout
          $timeout(function() {
            $('.' + focusElement).focus();
          });
        };

        scope.saveCycle = function() {

          scope.stageNoCycleShow = false;

          if(parseInt(onClickValue) !== parseInt(scope.stage.num_cycles)) {

            if(scope.stage.num_cycles >= scope.stage.auto_delta_start_cycle) {
              ExperimentLoader.saveCycle(scope);
              scope.cycleNoBackup = scope.stage.num_cycles;
            } else {
              var warningMessage = alerts.noOfCyclesWarning;
              scope.showMessage(warningMessage);
              scope.stage.num_cycles = scope.cycleNoBackup;
            }

          }
          noOfCycle = scope.stage.num_cycles;
        };

        scope.changeDelta = function() {

          if(scope.stage.stage_type === "cycling") {

            scope.stage.auto_delta = ! scope.stage.auto_delta;
            scope.delta_state = (scope.stage.auto_delta) ? "ON" : "OFF";
            ExperimentLoader.updateAutoDelata(scope).then(function() {
              console.log("Happy happy ---- Just testing ____-------______");
            });
          } else {
            var warningMessage = alerts.autoDeltaOnWrongStage;
            scope.showMessage(warningMessage);
          }
        };

        scope.saveStepName = function() {

          scope.step.name = (scope.step.name === "") ? null : scope.step.name;

          scope.stepNameShow = false;
          if(onClickValue !== scope.step.name) {
            ExperimentLoader.saveName(scope);
          }
        };

        scope.changeDuringStep = function() {

          scope.popUp = ! scope.popUp;
          scope.step.collect_data = ! scope.step.collect_data;
          ExperimentLoader.gatherDuringStep(scope);
        };

        scope.hidePopup = function() {
            scope.popUp = false;
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
