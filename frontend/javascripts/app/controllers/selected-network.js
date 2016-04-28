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
    //console.log($state, NetworkSettingsService.connectedWifiNetwork);
    if(NetworkSettingsService.connectedWifiNetwork.settings) {
      $scope.connectedSsid = NetworkSettingsService.connectedWifiNetwork.settings["wpa-ssid"].replace(new RegExp('"', "g"), "");
      if($state.params.name === $scope.connectedSsid) {
        console.log("I am connected");
        $scope.IamConnected = true;
      }
    }


  }
]);
