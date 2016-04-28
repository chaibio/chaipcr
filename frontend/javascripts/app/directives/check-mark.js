angular.module('ChaiBioTech').directive("checkMark", [
  '$rootScope',
  'NetworkSettingsService',
  '$state',
  function($rootScope, NetworkSettingsService, $state) {
    return {
      restrict: "E",
      replace: true,
      templateUrl: 'app/views/directives/check-mark.html',
      scope: {
        currentNetwork: "=currentNetwork",
        ssid: "@ssid"
      },
      link: function(scope, elem, attrs) {
        angular.element(elem).hide();
        scope.connected = false;
        scope.selected = false;

        scope.setSelected = function(myName, _ssid) {
          if(myName === _ssid) {
            scope.selected = true;
          } else {
            scope.selected = false;
          }
        };

        if($state.is('settings.networkmanagement.wifi')) {
          var _ssid = scope.ssid.replace(new RegExp(" ", "g"), "_");
          scope.setSelected($state.params.name, _ssid);
        }

        scope.$on('$stateChangeStart', function(event, toState, toParams) {
          var _ssid = scope.ssid.replace(new RegExp(" ", "g"), "_");
          scope.setSelected(toParams.name, _ssid);
        });

        scope.$on("new_wifi_connected", function() {
          var connectedNetworkSsid = NetworkSettingsService.connectedWifiNetwork.settings["wpa-ssid"].replace(new RegExp('"', 'g'), "");
          if(connectedNetworkSsid === scope.ssid) {
            angular.element(elem).show();
            scope.connected = true;
          } else {
            angular.element(elem).hide();
          }
        });
      }

    };
  }
]);
