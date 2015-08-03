window.ChaiBioTech.ngApp.directive('holdDuration', [
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
            scope.shown = scope.hidden = scope.$parent.timeFormating(scope.reading);
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
          var newHoldTime = scope.$parent.convertToMinute(scope.hidden);

          if(newHoldTime || newHoldTime === 0) {
            scope.reading = newHoldTime;
            $timeout(function() {
              ExperimentLoader.changeHoldDuration(scope.$parent).then(function(data) {
                console.log(data);
              });
            });

          } else {
            scope.hidden = scope.shown;
          }
        };
      }
    };
  }
]);
