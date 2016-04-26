angular.module('ChaiBioTech').directive('wifiLock', [
  '$rootScope',
  '$state',
  function($rootScope, $state) {
    return {
      templateUrl: 'app/views/directives/wifi-lock.html',
      restric: 'E',
      //replace: true,
      scope: {
        encryption: "@encryption",
        ssid: "@ssid"
      },

      link: function(scope, element, attr) {

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

        scope.$watch("encryption", function(val) {
          if(scope.encryption === "") {
            angular.element(element).hide();
          }
        });
        }
    };
  }
]);
