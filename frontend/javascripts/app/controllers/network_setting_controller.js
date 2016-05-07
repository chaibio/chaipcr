window.ChaiBioTech.ngApp.controller('NetworkSettingController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  'NetworkSettingsService',
  function($scope, $stateParams, User, $state, NetworkSettingsService) {

    $scope.wifiNetworks = {};

    $scope.findWifiNetworks = function() {
      console.log("called up");
      NetworkSettingsService.getWifiNetworks().then(function(result) {
        if(result.data) {
          $scope.wifiNetworks = result.data.scan_result;
        }

      });
    };

    $scope.getSettings = function() {
        /*NetworkSettingsService.getSettings().then(function(result) {
          console.log(result);
          if(result.data.settings) {
            $scope.currentNetwork = result.data;
          }
        });*/
        //NetworkSettingsService.getSettings();
    };

    $scope.findWifiNetworks();
    $scope.getSettings();

  }
]);
