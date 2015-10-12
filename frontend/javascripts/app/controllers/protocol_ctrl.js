window.ChaiBioTech.ngApp.controller('ProtocolCtrl', [
  '$scope',
  'ExperimentLoader',
  '$stateParams',
  'canvas',
  'Experiment',
  function($scope, ExperimentLoader, $stateParams, canvas, Experiment) {

    $scope.params = $stateParams;
    Experiment.get({id: $stateParams.id}).$promise.then(function (data) {
      Experiment.setCurrentExperiment(data.experiment);
    });

    this.ExperimentLoader = function() {
      ExperimentLoader.getExperiment().then(function(data) {
        $scope.protocol = data.experiment;
        canvas.init($scope);
      });
    };
  }
]);
