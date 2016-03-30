window.ChaiBioTech.ngApp.directive('temperature', [
  'ExperimentLoader',
  '$timeout',
  function(ExperimentLoader, $timeout) {
    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        unit: "@",
        reading: '=',
        action: '&' // Learn how to pass value in this scenario
      },

      templateUrl: 'app/views/directives/edit-value.html',

      link: function(scope, elem, attr) {

        scope.edit = false;
        scope.delta = true; // This is to prevent the directive become disabled, check delta in template, this is used for auto delta field
        var editValue;

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {

            scope.shown = Number(scope.reading);
            scope.hidden = Number(scope.reading);
          }
        });

        scope.editAndFocus = function(className) {

          scope.edit = ! scope.edit;
          editValue = Number(scope.hidden);

          $timeout(function() {
            $('.' + className).focus();
          });
        };

        scope.save = function() {
          console.log("saving ...... !");
          scope.edit = false;
          if(! isNaN(scope.hidden) && editValue !== Number(scope.hidden)) {

            scope.reading = scope.hidden;
            $timeout(function() {
              ExperimentLoader.changeTemperature(scope.$parent).then(function(data) {
                console.log(data);
              });
            });

          } else {
            scope.shown = scope.hidden = scope.reading;
          }
        };
      }
    };
  }
]);
