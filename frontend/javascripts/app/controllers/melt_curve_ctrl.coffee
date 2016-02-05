App.controller 'MeltCurveCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  ($scope, Experiment, $stateParams) ->

    $scope.curve_type = 'derivative'

    Experiment.getMeltCurveData($stateParams.id).then (resp) ->
      $scope.meltCurveData = resp.data;
      console.log resp.data

]