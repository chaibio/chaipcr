window.ChaiBioTech.ngApp

.controller 'HomeCtrl', [
  '$scope'
  'Experiment'
  '$window'
  '$modal'
  '$timeout'
  ($scope, Experiment, $window, $modal, $timeout) ->

    angular.element('body').addClass 'modal-form'
    $scope.$on '$destroy', ->
      angular.element('body').removeClass 'modal-form'

    $scope.experiments = null
    $scope.deleteMode = false

    @fetchExperiments = ->
      Experiment.query (experiments) ->
        $scope.experiments = experiments

    @fetchExperiments()

    @newExperiment = ->
      modalInstance = $modal.open
        templateUrl: 'app/views/experiment/create-experiment-name-modal.html'
        controller: 'CreateExperimentModalCtrl'

      modalInstance.result.then (cb) ->
        $timeout cb, 300

    @confirmDelete = (exp) ->
      if $scope.deleteMode
        exp.del = true

    @deleteExperiment = (data) =>
      experiment = data.experiment
      exp = new Experiment id: experiment.id
      exp.$remove =>
        $scope.experiments = _.reject $scope.experiments, (exp) ->
          exp.experiment.id is experiment.id
      , (resp) ->
        $window.alert resp.data.experiment?.errors?.base || 'Unable to delete experiment.'
        data.del = false

    @openExperiment = (exp) ->
      if exp.started_at isnt null
        $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}
      else
        $state.go 'edit-protocol', {id: exp.id}


    return

]
