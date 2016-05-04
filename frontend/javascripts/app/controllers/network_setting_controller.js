window.ChaiBioTech.ngApp.controller('NetworkSettingController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  'NetworkSettingsService',
  function($scope, $stateParams, User, $state, NetworkSettingsService) {

    $scope.wifiNetworks = {};

    $scope.findWifiNetworks = function() {

      NetworkSettingsService.getWifiNetworks().then(function(result) {
        if(result.data) {
          $scope.wifiNetworks = result.data.scan_result;
        }

      });
    };
    
    $scope.getSettings = function() {
        NetworkSettingsService.getSettings().then(function(result) {
          console.log(result);
          if(result.data) {
            $scope.currentNetwork = result.data;
          }
        });
    };

    $scope.findWifiNetworks();
    $scope.getSettings();

  }
]);
