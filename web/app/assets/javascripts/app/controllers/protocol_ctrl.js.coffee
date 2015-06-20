window.ChaiBioTech.ngApp

.controller 'ProtocolCtrl', [
  '$scope'
  '$state'
  'Experiment'
  '$stateParams'

  ($scope, $state, Experiment, $stateParams) ->

    $scope.protocol = {}

    $scope.protocol = Experiment.get {'id': $stateParams.id}, (data) ->
      $scope.protocol = data.experiment

    , (err) ->
          console.log "No Data from server", err
        
]
