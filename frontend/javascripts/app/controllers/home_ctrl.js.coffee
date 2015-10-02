window.ChaiBioTech.ngApp

.controller 'HomeCtrl', [
  '$scope'
  'Experiment'
  '$window'
  '$state'
  ($scope, Experiment, $window, $state) ->

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

    @openExperiment = (exp) ->
      if exp.started_at isnt null
        $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}
      else
        $state.go 'edit-protocol', {id: exp.id}


    return

]
