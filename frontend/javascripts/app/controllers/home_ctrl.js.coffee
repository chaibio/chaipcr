window.ChaiBioTech.ngApp

.controller 'HomeCtrl', [
  '$scope'
  'Experiment'
  '$window'
  '$uibModal'
  '$timeout'
  '$state'
  'User'
  'Status'
  'HomePageDelete',
  ($scope, Experiment, $window, $uibModal, $timeout, $state, User, Status, HomePageDelete) ->

    angular.element('body').addClass 'modal-form'
    $scope.$on '$destroy', ->
      angular.element('body').removeClass 'modal-form'

    $scope.experiments = null
    $scope.deleteMode = false

    User.getCurrent().then (resp) ->
      $scope.user = resp.data.user

    @fetchExperiments = ->
      Experiment.query (experiments) ->
        $scope.experiments = experiments

    @fetchExperiments()

    @newExperiment = ->
      modalInstance = $uibModal.open
        templateUrl: 'app/views/experiment/create-experiment-name-modal.html'
        controller: 'CreateExperimentModalCtrl'
        backdrop: false

      modalInstance.result.then (exp) ->
        $state.go 'edit-protocol', id: exp.id

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
      if not HomePageDelete.activeDelete
        state = Status.getData();
        if state.experiment_controller.machine.state == 'running' and exp.id == state.experiment_controller.expriment.id
          $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}

        if exp.started_at isnt null
          $state.go 'run-experiment', {id: exp.id, chart: 'amplification'}
        else
          $state.go 'edit-protocol', {id: exp.id}


    return

]
