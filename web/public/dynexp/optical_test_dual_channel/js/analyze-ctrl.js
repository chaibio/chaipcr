(function () {
   window.App.controller('AnalyzeCtrl', [
    '$scope',
    '$stateParams',
    'Constants',
    'Experiment',
    'GlobalService',
    function ($scope, $stateParams, Constants, Experiment, GlobalService) {

      $scope.loop = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
      $scope.analyzing = true;

      $scope.isPassed = function () {
        $scope.data = $scope.data || [];
        var passed = true;
        var valid;

        for (var i = $scope.data.length - 1; i >= 0; i--) {
          var datum = $scope.data[i];
          valid = datum.baseline[0][1] && datum.baseline[1][1];
          valid = valid && datum.water[0][1] && datum.water[1][1];
          valid = valid && datum.FAM[0][1] && datum.FAM[1][1];
          valid = valid && datum.HEX[0][1] && datum.HEX[1][1];

          if(!valid) {
            break;
          }
        }

        return valid;
      };

      Experiment.get($stateParams.id)
      .then(function (resp) {
        $scope.experiment = resp.data.experiment;
        Experiment.analyze($scope.experiment.id)
        .then(function (resp) {
          $scope.data = resp.data.optical_data;
          $scope.analyzing = false;
        })
        .catch(function () {
          $scope.analyzing = false;
        });
      });

    }
   ]);
}).call(window);