window.ChaiBioTech.ngApp.controller('NetworkSettingController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  'NetworkSettingsService',
  function($scope, $stateParams, User, $state, NetworkSettingsService) {

    $scope.wifiNetworks = {};

    $scope.findWifiNetworks = function() {
      
      NetworkSettingsService.getWifiNetworks();
    };

    $scope.findWifiNetworks();

  }
]);
