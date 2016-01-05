window.ChaiBioTech.ngApp.controller('systemController', [
  'Device',
  '$scope',
  function(Device, $scope) {

    $scope.getVersionSoft = function() {
      Device.getVersion(true).then(function(resp) {
        console.log(resp);
        $scope.data = resp;
      }, function(noData) {
        console.log(noData);
        // This is dummy data, to local checking. Will be removed.
        $scope.data = {"serial_number":"1234789127894212",
        "model_number":"M2342JA",
        "processor_architecture":"armv7l",
        "software":{"version":"1.0.0","platform":"S0100"}};
      });
    };

    $scope.checkUpdate = function() {

      Device.checkForUpdate().then(function(data) {
        console.log(data);
      }, function(noData) {
        console.log(noData);
      });
    };

    $scope.getVersionSoft();
  }

]);
