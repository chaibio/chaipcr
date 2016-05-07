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
    $scope.statusMessage = "";

    $scope.$on('new_wifi_result', function() {

      if(NetworkSettingsService.connectedWifiNetwork.state.status === "connected") {
        $scope.statusMessage = "";
        $state.go('settings.networkmanagement');
      } else {
        $scope.configureAsStatus(NetworkSettingsService.connectedWifiNetwork.state.status);
      }
    });

    $scope.credentials = {
      'wpa-ssid': $scope.name,
      'wpa-psk': "",
      'type': "dhcp"
    };

    if(NetworkSettingsService.connectedWifiNetwork.settings && NetworkSettingsService.connectedWifiNetwork.settings["wpa-ssid"]) {
      $scope.connectedSsid = NetworkSettingsService.connectedWifiNetwork.settings["wpa-ssid"].replace(new RegExp('"', "g"), "");
      if($state.params.name.replace(new RegExp('_', "g"), " ") === $scope.connectedSsid) {
        if(NetworkSettingsService.connectedWifiNetwork.state.status === "connected") {
          $scope.IamConnected = true;
        }
      }
    }

    $scope.connectWifi = function() {
      NetworkSettingsService.connectWifi($scope.credentials).then(function(data) {
        $scope.statusMessage = "";
        $scope.buttonValue = "CONNECTING";
      }, function(err) {
        console.log(err);
      });
    };

    $scope.configureAsStatus = function(status) {

      switch (status) {
        case "not_connected":
          $scope.buttonValue = "CONNECT";
          $scope.statusMessage = "";
          break;
        case "connecting":
          $scope.buttonValue = "CONNECTING";
          break;
        case "connection_error":
          $scope.buttonValue = "CONNECT";
          $scope.statusMessage = "Monkeys broke in and broke the cable. Couldn't connect";
          break;
        case "authentication_error":
          $scope.buttonValue = "CONNECT";
          $scope.statusMessage = "Monkeys broke in and stole everything. Couldn't connect";
          break;

      }
    };

  }
]);
