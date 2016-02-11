App.controller 'MeltCurveCtrl', [
  '$scope'
  'Experiment'
  '$stateParams'
  ($scope, Experiment, $stateParams) ->

    $scope.curve_type = 'derivative'

    console.log 'here'

    getMeltCurveData = (cb) ->
      Experiment.getMeltCurveData($stateParams.id).then (resp) ->
        $scope.meltCurveData = resp.data
        console.log resp.data
        cb(resp.data) if !!cb

    # getMeltCurveData()

]