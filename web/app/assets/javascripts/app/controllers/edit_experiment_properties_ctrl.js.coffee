window.ChaiBioTech.ngApp.controller 'EditExperimentPropertiesCtrl', [
  '$scope'
  'focus'
  'Experiment'
  '$stateParams'
  ($scope, focus, Experiment, $stateParams) ->

    $scope.experiment = {}

    Experiment.get {id: $stateParams.id}, (data) ->
      $scope.experiment = data.experiment

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
      Experiment.update $scope.experiment
]