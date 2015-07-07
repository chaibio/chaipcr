window.ChaiBioTech.ngApp.directive('arrow', [
  'ExperimentLoader',
  'canvas',
  function(ExperimentLoader, canvas) {

    return {
      restric: 'EA',
      replace: true,
      scope: false,
      templateUrl: 'app/views/directives/arrow.html',
      link: function(scope, elem, attr) {

        $(elem).click(function() {

          var action = $(this).attr('action');

          if(action === "previous") {
            scope.managePrevious(scope.fabricStep);
            return 0;
          }
            scope.manageNext(scope.fabricStep);
        });

        scope.manageNext = function(step) {

          var circle;
          if(step.nextStep) {
            circle = step.nextStep.circle;
            circle.manageClick();
            scope.applyValues(circle);
          } else if(step.parentStage.nextStage){
            circle = step.parentStage.nextStage.childSteps[0].circle;
            circle.manageClick();
            scope.applyValues(circle);
          }
        };

        scope.managePrevious = function(step) {

          var circle, stage;
          if(step.previousStep) {
            circle = step.previousStep.circle;
            circle.manageClick();
            scope.applyValues(circle);
          } else if(step.parentStage.previousStage) {
            stage = step.parentStage.previousStage;
            circle = stage.childSteps[stage.childSteps.length - 1].circle;
            circle.manageClick();
            scope.applyValues(circle);
          }
        };

        scope.applyValues = function(circle) {
          scope.$apply(function() {
            scope.step = circle.parent.model;
            scope.stage = circle.parent.parentStage.model;
            scope.fabricStep = circle.parent;
          });
        };
      }
    };
  }
]);
