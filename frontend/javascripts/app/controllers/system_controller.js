window.ChaiBioTech.ngApp.controller('systemController', [
  'Device',
  '$scope',
  'Status',
  function(Device, $scope, Status) {

    $scope.update_available = 'unavailable';
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

    $scope.$watch(function(){
      return Status.getData();
      }, function(data) {
        status = (data && data.device) ? data.device.update_available : 'unknown';
        if(status !== 'unknown')
          $scope.update_available = status;
    });

    $scope.openUpdateModal = function() {
      Device.openUpdateModal();
    };

    $scope.checkUpdate = function() {

      var checkPromise;
      $scope.checking_update = true;
      checkPromise = Device.checkForUpdate();
      checkPromise.then(function(is_available) {
        $scope.update_available = is_available;
        $scope.checkedUpdate = true;
        if (is_available === 'available') {
          $scope.openUpdateModal();
        }
      });
      checkPromise["catch"](function() {
        alert('Error while checking update!');
        $scope.update_available = 'unavailable';
         $scope.checkedUpdate = false;
      });
      return checkPromise["finally"](function() {
        $scope.checking_update = false;
      });
    };

    $scope.getVersionSoft();
  }

]);
