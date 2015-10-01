window.ChaiBioTech.ngApp.controller('ExperimentMenuOverlayCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  '$state'
  'AmplificationChartHelper'
  ($scope, $stateParams, Experiment, $state, AmplificationChartHelper) ->
    $scope.params = $stateParams
    $scope.maxCycle = 0

    Experiment.get(id: $stateParams.id).$promise.then (data) ->
      $scope.maxCycle = AmplificationChartHelper.getMaxExperimentCycle data.experiment

    $scope.deleteExperiment = (expId) ->
      exp = new Experiment id: expId
      exp.$delete id: expId, ->
        $state.go 'home'

])
