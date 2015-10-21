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

    pollTemperatures = ->
      tempPoll = $interval fetchTempLogs, 3000

    stopPolling = ->
      $interval.cancel tempPoll
      tempPoll = null

    getExperiment = ->
      Experiment.get(id: $params.id).$promise.then (resp) ->
        $scope.experiment = resp.experiment
        if resp.experiment.started_at and !resp.experiment.completed_at
          pollTemperatures()

    $scope.$watch ->
      Status.getData()
    , (data, oldData) ->
      return if !data
      return if !data.experimentController
      return if !data.experimentController.machine

      newState = data.experimentController.machine.state
      oldState = oldData?.experimentController?.machine?.state

      if $params.id and !$scope.experiment
        Experiment.get(id: $params.id).$promise.then (resp) ->
          $scope.experiment = resp.experiment

          pollTemperatures()
          return

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

      # if newState is 'Idle' and oldState and oldState isnt 'Idle'
      #   console.log test done



]