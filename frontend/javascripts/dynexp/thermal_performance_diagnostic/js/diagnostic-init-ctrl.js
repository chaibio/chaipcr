(function() {

  angular.module('dynexp.thermal_performance_diagnostic')
    .controller('DiagnosticInitCtrl', [
      '$scope',
      'dynexpExperimentService',
      '$state',
      '$uibModal',
      '$rootScope',
      'dynexpDeviceInfo',
      '$timeout',
      function($scope, Experiment, $state, $uibModal, $rootScope, DeviceInfo, $timeout) {

        $scope.error = true;
        $scope.modal = null;
        $scope.timeout = null;

        $scope.$on('$destroy', function() {
          if ($scope.timeout) {
            $timeout.cancel($scope.timeout);
          }
        });

        $scope.stopExperiment = function() {
          $state.go('settings.root');
        };

        $scope.checkMachineStatus = function() {

          DeviceInfo.getInfo($scope.check).then(function(deviceStatus) {
            // Incase connected
            if ($scope.modal) {
              $scope.modal.close();
              $scope.modal = null;
            }

            if (deviceStatus.data.optics.lid_open === "true" || deviceStatus.data.lid.open === true) { // lid is open
              $scope.error = true;
              $scope.lidMessage = "Close lid to begin.";
            } else {
              $scope.error = false;
            }
          }, function(err) {
            // Error
            $scope.error = true;
            $scope.lidMessage = "Cant connect to machine.";

            if (err.status === 500) {

              if (!$scope.modal) {
                var scope = $rootScope.$new();
                scope.message = {
                  title: "Cant connect to machine.",
                  body: err.data.errors || "Error"
                };

                $scope.modal = $uibModal.open({
                  templateUrl: 'dynexp/thermal_performance_diagnostic/views/modal-error.html',
                  scope: scope
                });
              }
            }
          });

          $scope.timeout = $timeout($scope.checkMachineStatus, 1000);
        };

        $scope.proceed = function() {

          Experiment.create({ guid: 'thermal_performance_diagnostic', name: 'thermal_performance_diagnostic' }).then(function(resp) {
            $timeout.cancel($scope.timeout);
            $scope.experiment = resp.data.experiment;

            var startPromise = Experiment.startExperiment(resp.data.experiment.id);
            var newExpId = resp.data.experiment.id;

            startPromise.then(function() {
              $state.go('thermal_performance_diagnostic.diagnostic', {
                id: newExpId
              });
            });

            startPromise.catch(function(err) {
              var error = 'Unable to start experiment!';
              if (err.data.status) {
                if (err.data.status.error) error = err.data.status.error;
              }

              var scope = $rootScope.$new();
              scope.message = {
                title: "Experiment can't be started",
                body: error
              };

              $uibModal.open({
                templateUrl: 'dynexp/thermal_performance_diagnostic/views/modal-error.html',
                scope: scope
              });

            });
          });
        };

        $scope.checkMachineStatus();
      }
    ]);

})();
