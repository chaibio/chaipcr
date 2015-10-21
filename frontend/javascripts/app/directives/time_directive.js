window.ChaiBioTech.ngApp.directive('time', [
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
        delta: '=',
        action: '&' // Learn how to pass value in this scenario
      },

      transclude: true,
      templateUrl: 'app/views/directives/temp-time.html',

      link: function(scope, elem, attr) {

        scope.edit = false;
        var editValue;

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {
            scope.shown = scope.hidden = scope.$parent.timeFormating(scope.reading);
          }
        });

        scope.editAndFocus = function(className) {

          if(scope.delta) {
            editValue = scope.hidden;
            scope.edit = ! scope.edit;
            $timeout(function() {
              $('.' + className).focus();
            });
          }
        };

        scope.save = function() {

          scope.edit = false;
          var newHoldTime = scope.$parent.convertToMinute(scope.hidden);
          editValue = scope.$parent.convertToMinute(editValue);
          
          if((newHoldTime || newHoldTime === 0) && editValue !== newHoldTime) {
            scope.reading = newHoldTime;
            $timeout(function() {
              ExperimentLoader.changeDeltaTime(scope.$parent).then(function(data) {
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
