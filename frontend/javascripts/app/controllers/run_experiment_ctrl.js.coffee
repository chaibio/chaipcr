window.ChaiBioTech.ngApp.controller 'RunExperimentCtrl', [
  '$scope'
  '$stateParams'
  '$state'
  ($scope, $stateParams, $state) ->
    @chart = $stateParams.chart

    @changeChart = (chart) ->
      $state.go 'run-experiment', {id: $stateParams.id, chart: chart}, notify: false
      @chart = chart

]