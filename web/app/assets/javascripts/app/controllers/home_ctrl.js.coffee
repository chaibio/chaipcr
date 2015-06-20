window.ChaiBioTech.ngApp

.controller 'HomeCtrl', [
  '$scope'
  'Experiment'
  ($scope, Experiment) ->

    $scope.experiments = []

    @fetchExperiments = ->
      Experiment.query (experiments) ->
        $scope.experiments = experiments

    @fetchExperiments()

    @newExperiment = ->
      $scope.experiments = []
      exp = new Experiment
        experiment:
          name: 'New Experiment'
          protocol: {}

      exp.$save (data) =>
        @fetchExperiments()


    return

]
