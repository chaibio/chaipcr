window.ChaiBioTech.ngApp.controller 'EditExperimentPropertiesCtrl', [
  '$scope'
  'focus'
  'Experiment'
  '$stateParams',
  'expName',
  'Protocol'
  'Status'
  '$timeout'
  ($scope, focus, Experiment, $stateParams, expName, Protocol, Status, $timeout) ->

    if !Experiment.getCurrentExperiment()
      Experiment.get {id: $stateParams.id}, (data) ->
        Experiment.setCurrentExperiment data.experiment
        $scope.experiment = data.experiment
        $scope.experimentOrig = angular.copy data.experiment
    else
      $scope.experiment = Experiment.getCurrentExperiment()
      $scope.experimentOrig = angular.copy $scope.experiment

    $scope.editExpNameMode = false

    $scope.$on 'status:data:updated', (e, data) ->
      if parseInt(data?.experiment_controller?.expriment?.id) is parseInt($stateParams.id)
        $scope.experiment.started_at = data.experiment_controller.expriment.started_at
        $scope.experiment.completed_at = data.experiment_controller.expriment.completed_at

    $scope.removeMessages = ->
      $scope.success = null
      $scope.errors = null


    $scope.typeSelected = (type) ->
      $scope.selectedType = type

    $scope.focusExpName = ->
      $scope.removeMessages()
      $scope.editExpNameMode = true
      focus('editExpNameMode')


    $scope.focusLidTemp = ->
      $scope.removeMessages()
      if $scope.experiment?.started_at
        $scope.errors = "Experiment has been run."
        return

      $scope.editLidTempMode = true
      focus('editLidTempMode')

    $scope.editModeOff = ->
      $scope.editExpNameMode = false
      $scope.editLidTempMode = false

    $scope.saveExperiment = (exp)->
      return if $scope.expForm.$invalid
      promise = Experiment.update({id: exp.id}, experiment: exp).$promise

      promise.then ->
        $scope.success = "Experiment name updated."
        expName.updateName(exp.name)
        $timeout (() ->
          $scope.success = ""
          ), 2000

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig

      promise.finally ->
        $scope.editModeOff()

    $scope.updateProtocol = (data) ->
      return if $scope.expForm.lidTemp.$invalid
      promise = Protocol.update data

      promise.success ->
        $scope.success = "Lid temperature updated."

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig

      promise.finally ->
        $scope.editModeOff()
]
