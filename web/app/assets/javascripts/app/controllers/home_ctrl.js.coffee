window.ChaiBioTech.ngApp

.controller 'HomeCtrl', [
  '$scope'
  'Experiment'
  ($scope, Experiment) ->

    $scope.experiments = null

    $scope.deleteMode = false

    @fetchExperiments = ->
      Experiment.query (experiments) ->
        $scope.experiments = experiments

    @fetchExperiments()

    @newExperiment = ->
      experiments = angular.copy $scope.experiments
      $scope.experiments = null
      exp = new Experiment
        experiment:
          name: 'New Experiment'
          protocol: {}

      exp.$save (data) =>
        @fetchExperiments()
      , ->
        $scope.experiments = experiments

    @confirmDelete = (exp) ->
      if $scope.deleteMode
        exp.del = true

    @deleteExperiment = (expId) =>
      exp = new Experiment id: expId
      exp.$remove =>
        @fetchExperiments()

    return

]
