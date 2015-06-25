window.ChaiBioTech.ngApp

.controller 'ProtocolCtrl', [
  '$scope'
  'ExperimentLoader'
  '$stateParams'

  ($scope, ExperimentLoader, $stateParams) ->

    @ExperimentLoader = ->
      ExperimentLoader.getExperiment().then (data) ->
        $scope.protocol = data.experiment
        ## Load canvas here

    @ExperimentLoader()

]
