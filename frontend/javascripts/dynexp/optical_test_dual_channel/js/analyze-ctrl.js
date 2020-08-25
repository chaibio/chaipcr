angular.module('dynexp.optical_test_dual_channel').controller('OpticalTestDualChannelAnalyzeCtrl', [
  '$scope',
  '$stateParams',
  'OpticalTestDualChannelConstants',
  'dynexpExperimentService',
  'dynexpGlobalService',
  '$timeout',
  function($scope, $stateParams, Constants, Experiment, GlobalService, $timeout) {

    $scope.loop = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    $scope.analyzing = true;
    $scope.valid = false;

    $scope.isPassed = function() {
      $scope.data = $scope.data || [];
      var passed = true;
      var valid;

      for (var i = $scope.data.length - 1; i >= 0; i--) {
        var datum = $scope.data[i];
        valid = datum.baseline[0][1] && datum.baseline[1][1];
        valid = valid && datum.water[0][1] && datum.water[1][1];
        valid = valid && datum.FAM[0][1] && datum.FAM[1][1];
        valid = valid && datum.HEX[0][1] && datum.HEX[1][1];

        if (!valid) {
          break;
        }
      }

      return valid && $scope.valid;
    };

    $scope.analyzeExperiment = function() {
      Experiment.get($stateParams.id)
        .then(function(resp) {
          $scope.experiment = resp.data.experiment;
          Experiment.analyze($scope.experiment.id)
            .then(function(resp) {
              if (resp.status == 200) {
                $scope.data = resp.data.optical_data;
                $scope.custom_error = resp.data.error;
                $scope.valid = resp.data.valid;
                $scope.analyzing = false;
              } else if (resp.status == 202) {
                $timeout($scope.analyzeExperiment, 1000);
              }
            })
            .catch(function(resp) {
              if (resp.status == 500) {
                $scope.custom_error = resp.data.errors || "An error occured while trying to analyze the experiment results.";
                $scope.analyzing = false;
              } else if (resp.status == 503) {
                $timeout($scope.analyzeExperiment, 1000);
              }
            });
        });

    };

    $scope.analyzeExperiment();

  }
]);
