window.ChaiBioTech.ngApp.directive('rampSpeed', [
  'ExperimentLoader',
  '$timeout',
  function(ExperimentLoader, $timeout) {
    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        unit: "@",
        reading: '='
      },
      templateUrl: 'app/views/directives/edit-value.html',

      link: function(scope, elem, attr) {

        scope.edit = false;
        scope.delta = true; // This is to prevent the directive become disabled, check delta in template, this is used for auto delta field

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {
            console.log(Number(scope.reading));
            scope.shown = (Number(scope.reading) === 0) ? "AUTO" : scope.reading;
            scope.hidden = Number(scope.reading);
          }
        });


        scope.editAndFocus = function(className) {
          scope.edit = ! scope.edit;
          $timeout(function() {
            $('.' + className).focus();
          });
        };

        scope.save = function() {
          
          scope.edit = false;
          if(! isNaN(scope.hidden)) {

            scope.reading = scope.hidden;
            $timeout(function() {
              ExperimentLoader.changeRampSpeed(scope.$parent).then(function(data) {
                console.log(data);
              });
            });

          } else {
            scope.shown = "AUTO";
            scope.hidden = 0;
          }

        };
      }
    };
  }
]);
