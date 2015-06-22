window.ChaiBioTech.ngApp

.controller 'ProtocolCtrl', [
  '$scope'
  '$state'
  'ExperimentLoader'
  '$stateParams'

  ($scope, $state, ExperimentLoader, $stateParams) ->

    @ExperimentLoader = ->
      ExperimentLoader.getExperiment().then (data) ->
        $scope.protocol = data.experiment
        ## Load canvas here

    @ExperimentLoader()

]
