window.ChaiBioTech.ngApp.service('ExperimentLoader', [
  'Experiment', '$q', '$stateParams', function(Experiment, $q, $stateParams) {

    this.getExperiment = function() {
      var delay;
      delay = $q.defer();
      Experiment.get({'id': $stateParams.id}, function(data) {
        delay.resolve(data)
      }, function() {
        delay.reject('Cant bring the data');
      });

      return delay.promise
    };


  }
]);
