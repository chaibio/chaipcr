window.ChaiBioTech.ngApp.controller 'DiagnosticWizardCtrl', [
  '$scope'
  'Experiment'
  'Status'
  '$interval'
  'DiagnosticWizardService'
  '$stateParams'
  '$state'
  ($scope, Experiment, Status, $interval, DiagnosticWizardService, $params, $state) ->

    Status.startSync()
    $scope.$on '$destroy', ->
      Status.stopSync()
      stopPolling()

    tempPoll = null
    $scope.lidTemps = null
    $scope.blockTemps = null
    creating = false

    fetchTempLogs = ->
      Experiment.getTemperatureData($scope.experiment.id).then (resp) ->
        $scope.lidTemps = DiagnosticWizardService.temperatureLogs(resp.data).getLidTemps()
        $scope.blockTemps = DiagnosticWizardService.temperatureLogs(resp.data).getBlockTemps()
        $scope.elapsedTime = resp.data[resp.data.length-1]?.temperature_log?.elapsed_time || 0

    pollTemperatures = ->
      tempPoll = $interval fetchTempLogs, 3000

    stopPolling = ->
      $interval.cancel tempPoll
      tempPoll = null

    getExperiment = (cb) ->
      cb = cb || angular.noop
      Experiment.get(id: $params.id).$promise.then (resp) ->
        cb resp

    $scope.$watch ->
      Status.getData()
    , (data, oldData) ->
      return if !data
      return if !data.experimentController
      return if !data.experimentController.machine

      newState = data.experimentController.machine.state
      oldState = oldData?.experimentController?.machine?.state
      $scope.status = data.experimentController.machine.thermal_state

      if $params.id and !$scope.experiment
        getExperiment (resp) ->
          $scope.experiment = resp.experiment
          if resp.experiment.started_at and !resp.experiment.completed_at
            pollTemperatures()
          else
            fetchTempLogs()

      if newState is 'Idle' and !$params.id and !creating
        creating = true
        exp = new Experiment
          experiment:
            name: 'New Experiment [For diagnostic test]'
            guid: null

        exp.$save().then (resp) ->
          $scope.experiment = resp.experiment
          Experiment.startExperiment(resp.experiment.id).then ->
            $state.go 'diagnostic-wizard', {id: resp.experiment.id}

      if newState is 'Idle' and oldState isnt 'Idle'
        stopPolling()
        getExperiment (resp) ->
          $scope.experiment = resp.experiment


    $scope.stopExperiment = ->
      Experiment.stopExperiment(id: $scope.experiment.id)

]