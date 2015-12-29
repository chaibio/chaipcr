window.ChaiBioTech.ngApp.directive('confirmPass', [
  'ExperimentLoader',
  '$timeout',
  'canvas',
  'popupStatus',

  function(ExperimentLoader, $timeout, canvas, popupStatus) {
    return {
      restric: 'A',
      require: 'ngModel',
      scope: {
        confirmPass: "@"
      },

      link: function(scope, elem, attr, controller) {
          //console.log(controller, scope, "DASDASDASDASDA");
          scope.$watch('confirmPass', function(newVal) {
            /*console.log("alright");
            if(controller.$modelValue !== scope.confirmPass) {
              controller.$setValidity("passwordMatch", false);
              //return false;
            } else {
              controller.$setValidity("passwordMatch", true);
            }*/
          });
          controller.$setValidity("passwordMatch", true);
          controller.$parsers.push(function(input) {
            console.log("input", input, "okay", scope.confirmPass);
            if(input === scope.confirmPass) {
              console.log("equal");
              controller.$setValidity("passwordMatch", true);
              //return true;
            } else {
              controller.$setValidity("passwordMatch", false);
              //return false;
            }
            return input;
          });
      }
    };
  }
]);
