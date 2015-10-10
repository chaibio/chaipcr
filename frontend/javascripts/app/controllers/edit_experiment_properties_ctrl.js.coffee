window.ChaiBioTech.ngApp.controller 'EditExperimentPropertiesCtrl', [
  '$scope'
  'focus'
  'Experiment'
  '$stateParams',
  'expName',
  'Protocol'
  'Status'
  ($scope, focus, Experiment, $stateParams, expName, Protocol, Status) ->

    $scope.experiment = {}

    Experiment.get {id: $stateParams.id}, (data) ->
      $scope.experiment = data.experiment
      $scope.experimentOrig = angular.copy $scope.experiment

    $scope.editExpNameMode = false

    # $scope.expTypes = [
    #   {text: 'END POINT'}
    #   {text: 'PRESENCE/ABSENSE'}
    #   {text: 'GENOTYPING'}
    #   {text: 'QUANTIFICATION'}
    # ]

    $scope.$watch ->
      Status.getData()
    , (data) ->
      if parseInt(data?.experimentController?.expriment?.id) is parseInt($stateParams.id)
        $scope.experiment.started_at = data.experimentController.expriment.started_at
        $scope.experiment.completed_at = data.experimentController.expriment.completed_at

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
      if $scope.running
        $scope.errors = "Experiment is currently running."
        return

      if !$scope.running and ($scope.experiment.started_at isnt null and $scope.experiment.completed_at isnt null)
        $scope.errors = "Experiment has already been run."
        return

      $scope.editLidTempMode = true
      focus('editLidTempMode')

    $scope.editModeOff = ->
      $scope.editExpNameMode = false
      $scope.editLidTempMode = false

    $scope.saveExperiment = ->
      return if $scope.expForm.$invalid
      promise = Experiment.update({id: $scope.experiment.id}, experiment: $scope.experiment).$promise

      promise.then ->
        $scope.success = "Experiment name updated successfully"
        expName.updateName($scope.experiment.name)

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig

      promise.finally ->
        $scope.editModeOff()

    $scope.updateProtocol = (data) ->
      return if $scope.expForm.lidTemp.$invalid
      promise = Protocol.update data

      promise.success ->
        $scope.success = "Protocol lid temperature updated successfully"

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig

      promise.finally ->
        $scope.editModeOff()
]
