window.ChaiBioTech.ngApp.controller('ProtocolCtrl', [
  '$scope',
  'ExperimentLoader',
  '$stateParams',
  'canvas',
  function($scope, ExperimentLoader, $stateParams, canvas) {

    this.ExperimentLoader = function() {
      ExperimentLoader.getExperiment().then(function(data) {
        $scope.protocol = data.experiment;
        canvas.init($scope);
      });
    };

    //this.ExperimentLoader();
  }
]);
