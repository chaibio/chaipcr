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

        //console.log(scope, "sdfgsfgss");

        scope.stepNameShow = false;
        scope.stageNoCycleShow = false;
        scope.popUp = false;

        scope.$on("dataLoaded", function() {
          // there is a slight delay for the controller to catch up so wait for it and load
          scope.off = scope.stage.auto_delta;
          scope.delta_state = (scope.stage.auto_delta) ? "ON" : "OFF";

          scope.gather_data_state = (scope.step.collect_data || scope.step.ramp.collect_data) ? "ON" : "OFF";

          scope.duringStep = scope.step.collect_data;
          scope.duringRamp = scope.step.ramp.collect_data;

          scope.gatherDataState = (!scope.duringStep && !scope.duringRamp) ? false : true ;

        });
        // Field is controller members
        scope.checkIfEnter = function(evt, field){
          if(evt.which === 13) {
            scope[field] = false;
          }
        };
        // focusElement is the classname of the desired input box to be shown
        scope.clickOnField = function(field, focusElement) {

          scope[field] = true;
          // It takes while after render to focus, thats y we have a $timeout
          $timeout(function() {
            $('.' + focusElement).focus();
          });
        }

        scope.changeDelta = function() {

          if(scope.stage.stage_type == "cycling") {

            scope.stage.auto_delta = scope.off = ! scope.stage.auto_delta;
            scope.delta_state = (scope.stage.auto_delta) ? "ON" : "OFF";
          } else {
            alert("Plese select a yclin stage");
          }
        }

        scope.showPopUp = function() {

          scope.popUp = ! scope.popUp;
        }

        scope.changeDuringStep = function() {

          scope.popUp = ! scope.popUp;
          scope.duringStep = scope.step.collect_data = ! scope.step.collect_data;
          scope.gatherDataState = (!scope.duringStep && !scope.duringRamp) ? false : true ;
        }

        scope.changeDuringRamp = function() {

          scope.popUp = ! scope.popUp;
          scope.duringRamp = scope.step.ramp.collect_data = ! scope.step.ramp.collect_data;
          scope.gatherDataState = (!scope.duringStep && !scope.duringRamp) ? false : true ;
        }

      }
    }
  }
]);
