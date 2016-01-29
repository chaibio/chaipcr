(function () {

  var app = window.HeaderStatus = angular.module('wizard.header', [
    'status.service',
    'experiment.service'
  ]);

  app.directive('wizardHeader', [
    'Status',
    '$rootScope',
    'Experiment',
    function (Status, $rootScope, Experiment) {

      function linkFunc ($scope, elem, attrs) {

        function getExperiment () {
          Experiment.get($scope.experimentId).then(function (resp) {
            $scope.experiment = resp.data.experiment;
          });
        }

        $scope.cancelText = $scope.cancelText || 'CANCEL';

        $rootScope.$on('status:data:updated', function (e, data, oldData) {
          if (!oldData) return;
          if (!data) return;
          $scope.status = data.experiment_controller.machine.state;
          if (($scope.status !== oldData.experiment_controller.machine.state || !$scope.experiment) && $scope.experimentId) {
            getExperiment();
          }
        });

        $scope.doCancel = function () {
          $scope.onCancel();
        };


      }

      return {
        restrict: 'EA',
        replace: true,
        transclude: true,
        scope: {
                experimentId: '=',
                onCancel: '&',
                cancelText: '@'
              },
        templateUrl: '/dynexp/libs/views/wizard-header.html',
        link: linkFunc
      };

    }
  ]);


}).call(window);