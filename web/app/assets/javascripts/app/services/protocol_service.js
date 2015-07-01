window.ChaiBioTech.ngApp.service('ExperimentLoader', [
  'Experiment',
  '$q',
  '$stateParams',
  '$rootScope',
  function(Experiment, $q, $stateParams, $rootScope) {

    this.protocol = {};
    this.index = 0;

    this.getExperiment = function() {

      var delay, that = this;
      delay = $q.defer();
      Experiment.get({'id': $stateParams.id}, function(data) {
        that.protocol = data.experiment;
        $rootScope.$broadcast("dataLoaded");
        delay.resolve(data)
      }, function() {
        delay.reject('Cant bring the data');
      });

      return delay.promise
    };

    this.loadFirstStages = function() {
      return this.protocol.protocol.stages[0].stage;
    };

    this.loadFirstStep = function() {
      return this.protocol.protocol.stages[0].stage.steps[0].step;
    }

    this.getNew = function() {
      console.log(this.protocol);
      return this.protocol.protocol.stages[1].stage
    }


  }
]);
