window.ChaiBioTech.ngApp.controller('selectedNetwork', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  'NetworkSettingsService',
  function($scope, $stateParams, User, $state, NetworkSettingsService) {

    $scope.name = $state.params.name.replace(new RegExp("_", "g"), " ");
    $scope.buttonValue = "CONNECT";
    $scope.IamConnected = false;
    $scope.authentication_error = false;
    $scope.credentials = {
      'wpa-ssid': $scope.name,
      'wpa-psk': "",
      'type': "dhcp"
    };
    //console.log($state, NetworkSettingsService.connectedWifiNetwork);
    if(NetworkSettingsService.connectedWifiNetwork.settings && NetworkSettingsService.connectedWifiNetwork.settings["wpa-ssid"]) {
      $scope.connectedSsid = NetworkSettingsService.connectedWifiNetwork.settings["wpa-ssid"].replace(new RegExp('"', "g"), "");
      if($state.params.name.replace(new RegExp('_', "g"), " ") === $scope.connectedSsid) {
        $scope.IamConnected = true;
      }
    }

    $scope.connectWifi = function() {
      NetworkSettingsService.connectWifi($scope.credentials).then(function(data) {
        NetworkSettingsService.getSettings();
        $state.go('settings.networkmanagement');
        console.log(data);
      }, function(err) {
        console.log(err);
      });
    };
    // Now work on refresh, when we refresh IamConnected is false
  }
]);
