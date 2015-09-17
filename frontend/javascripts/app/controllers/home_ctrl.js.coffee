window.ChaiBioTech.ngApp

.controller 'HomeCtrl', [
  '$scope'
  'Experiment'
  '$window'
  ($scope, Experiment, $window) ->

    $scope.experiments = null

    $scope.deleteMode = false

    @fetchExperiments = ->
      Experiment.query (experiments) ->
        $scope.experiments = experiments

    @fetchExperiments()

    @newExperiment = ->
      exp = new Experiment
        experiment:
          name: 'New Experiment'
          protocol: {}

      exp.$save (data) =>
        @fetchExperiments()

    @confirmDelete = (exp) ->
      if $scope.deleteMode
        exp.del = true

    @deleteExperiment = (data) =>
      experiment = data.experiment
      exp = new Experiment id: experiment.id
      exp.$remove =>
        $scope.experiments = _.reject $scope.experiments, (exp) ->
          exp.experiment.id is experiment.id
      , (resp) ->
        $window.alert resp.data.experiment?.errors?.base || 'Unable to delete experiment.'
        data.del = false

    return

]
