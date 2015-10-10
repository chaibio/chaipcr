window.ChaiBioTech.ngApp.controller('ProtocolCtrl', [
  '$scope',
  'ExperimentLoader',
  '$stateParams',
  'canvas',
  'Experiment',
  function($scope, ExperimentLoader, $stateParams, canvas, Experiment) {

    $scope.params = $stateParams;

    this.ExperimentLoader = function() {
      ExperimentLoader.getExperiment().then(function(data) {
        Experiment.setCurrentExperiment(data.experiment)
        $scope.protocol = data.experiment;
        canvas.init($scope);
      });
    };
  }
]);
