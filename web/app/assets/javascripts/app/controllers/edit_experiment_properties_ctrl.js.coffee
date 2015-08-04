window.ChaiBioTech.ngApp.controller 'EditExperimentPropertiesCtrl', [
  '$scope'
  'focus'
  'Experiment'
  '$stateParams'
  ($scope, focus, Experiment, $stateParams) ->

    $scope.experiment = {}

    Experiment.get {id: $stateParams.id}, (data) ->
      $scope.experiment = data.experiment
      $scope.experimentOrig = angular.copy $scope.experiment

    $scope.editExpNameMode = false

    $scope.expTypes = [
      {text: 'END POINT'}
      {text: 'PRESENCE/ABSENSE'}
      {text: 'GENOTYPING'}
      {text: 'QUANTIFICATION'}
    ]

    $scope.typeSelected = (type) ->
      $scope.selectedType = type

    $scope.focusExpName = ->
      $scope.editExpNameMode = true
      focus('editExpNameMode')

    $scope.saveExperiment = ->
      promise = Experiment.update({id: $scope.experiment.id}, experiment: $scope.experiment).$promise

      promise.then ->
        $scope.success = "Experiment updated successfully"

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig

      promise.finally ->
        $scope.editExpNameMode = false
]