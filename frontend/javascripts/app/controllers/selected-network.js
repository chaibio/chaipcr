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
      'wpa-psk': ""
    };
    //console.log($state, NetworkSettingsService.connectedWifiNetwork);
    if(NetworkSettingsService.connectedWifiNetwork.settings) {
      $scope.connectedSsid = NetworkSettingsService.connectedWifiNetwork.settings["wpa-ssid"].replace(new RegExp('"', "g"), "");
      if($state.params.name.replace(new RegExp('_', "g"), " ") === $scope.connectedSsid) {
        $scope.IamConnected = true;
      }
    }

    $scope.connectWifi = function() {
      console.log($scope.credentials);
      //NetworkSettingsService.connectWifi();
    };
    // Now work on refresh, when we refresh IamConnected is false
  }
]);
