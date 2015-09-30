window.ChaiBioTech.ngApp.controller('ExperimentMenuOverlayCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  '$state'
  ($scope, $stateParams, Experiment, $state) ->
    $scope.params = $stateParams

    $scope.deleteExperiment = (expId) ->
      exp = new Experiment id: expId
      exp.$delete id: expId, ->
        $state.go 'home'

])
