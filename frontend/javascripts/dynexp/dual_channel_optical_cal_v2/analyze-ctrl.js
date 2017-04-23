(function() {
  window.App.controller('DualChannelOpticalCalAnalyzeCtrl', [
    '$scope',
    '$stateParams',
    'dualChannelOpticalCal2Constants',
    'dynexpExperimentService',
    'dynexpGlobalService',
    function($scope, $stateParams, Constants, Experiment, GlobalService) {

      $scope.loop = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
      $scope.analyzing = true;

      getStepIds = function(experiment) {
        var steps = GlobalService.getExperimentSteps(experiment);
        steps = _.filter(steps, function(step) {
          return step.name !== 'Swap';
        });
        return _.map(steps, function(step) {
          return step.id;
        });
      };

      mutateResponseData = function(data) {
        var newData = [];
        for (var i = 0; i < data.length; i++) {
          var stepData = data[i].data;
          var dataArr = [];
          for (var ii = 0; ii < stepData.length; ii++) {
            dataArr.push(stepData[ii].fluorescence_value);
          }
          newData.push(dataArr);
        }
        return newData;
      };

      $scope.isPassed = function(baseline, water, fam, hex) {
        var pass = true;
        pass = baseline >= Constants.BASELINE.MIN && baseline >= Constants.BASELINE.MAX;
        pass = pass && water >= Constants.WATER.MIN && water >= Constants.WATER.MAX;
        pass = pass && fam >= Constants.FAM.MIN && fam >= Constants.FAM.MAX;
        pass = pass && hex >= Constants.HEX.MIN && hex >= Constants.HEX.MAX;
        return pass;
      };

      Experiment.get($stateParams.id)
        .then(function(resp) {
          $scope.experiment = resp.data.experiment;
          Experiment.getStepsData($scope.experiment.id, getStepIds($scope.experiment))
            .then(function(resp) {
              $scope.data = mutateResponseData(resp.data.fluorescence_data);
              console.log($scope.data);
              $scope.analyzing = false;
            });
        });

    }
  ]);
}).call(window);
