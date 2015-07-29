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

        scope.$watch("reading", function(val) {

          if(angular.isDefined(scope.reading)) {
            scope.shown = scope.hidden = scope.timeFormating();
          }
        });

        scope.timeFormating = function() {
          var hour = Math.floor(scope.reading / 60);
          hour = (hour < 10 && hour >= 0) ? "0" + hour : hour;

          var min = scope.reading % 60;
          min = (min < 10) ? "0" + min : min;

          return hour + ":" + min;
        };

        scope.editAndFocus = function(className) {

          if(scope.delta) {
            scope.edit = ! scope.edit;
            $timeout(function() {
              $('.' + className).focus();
            });
          }
        };

        scope.convertToMinute = function() {

          var deltaTime = scope.hidden;

          var value = deltaTime.indexOf(":");
          if(value != -1) {
            var hr = deltaTime.substr(0, value);
            var min = deltaTime.substr(value + 1);

            if(isNaN(hr) || isNaN(min)) {
              deltaTime = null;
              alert("Please enter a valid value");
              return false;
            } else {
              deltaTime = (hr * 60) + (min * 1);
              return deltaTime;
            }
          }

          if(isNaN(deltaTime) || !deltaTime) {
            alert("Please enter a valid value");
            return false;
          } else {
            return parseInt(Math.abs(deltaTime));
          }
        };

        scope.save = function() {

          scope.edit = false;

          if(scope.convertToMinute(scope.hidden)) {

            scope.reading = scope.convertToMinute(scope.hidden);
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
