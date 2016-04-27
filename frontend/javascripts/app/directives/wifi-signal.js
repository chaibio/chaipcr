angular.module('ChaiBioTech').directive('wifiSignal', [
  '$state',
  function($state) {
    return {
      templateUrl: 'app/views/directives/wifi-signal.html',
      restric: 'E',
      //replace: true,
      scope: {
        ssid: "@ssid",
        quality: "@quality"
      },

      link: function(scope, element, attr) {

        scope.arc4Signal = true;
        scope.arc3Signal = false;
        scope.arc2Signal = false;
        scope.arc1Signal = false;
        scope.selected = false;

        if($state.is('settings.networkmanagement.wifi')) {
          if($state.params.name === scope.ssid) {
            scope.selected = true;
          } else {
            scope.selected = false;
          }
        }

        scope.$on('$stateChangeStart', function(event, toState, toParams) {

          if(toParams.name === scope.ssid) {
            scope.selected = true;
          } else {
            scope.selected = false;
          }
        });

        scope.$watch("quality", function() {
          var quality = scope.quality;
          scope.rerender(Number(quality));
        });

        scope.rerender = function(quality) {
          if(quality && Number(quality) <= 100) {
            if(quality > 90) {
              scope.arc1Signal = true;
            }
            if(quality > 50) {
              scope.arc2Signal = true;
            }
            if(quality > 25) {
              scope.arc3Signal = true;
            }
            if(quality > 0) {
              scope.arc4signal = true;
            }
          }
        };

      }
    };
  }
]);
