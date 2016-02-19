window.ChaiBioTech.ngApp.controller('ExperimentMenuOverlayCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  '$state'
  'AmplificationChartHelper'
  'Status',
  '$timeout'
  '$rootScope'
  ($scope, $stateParams, Experiment, $state, AmplificationChartHelper, Status, $timeout, $rootScope) ->
    $scope.params = $stateParams
    $scope.lidOpen = false
    $scope.showProperties = false;

    $scope.deleteExperiment = ->
      exp = new Experiment id: $stateParams.id
      exp.$delete id: $stateParams.id, ->
        $state.go 'home'

    $scope.$watch 'showProperties', (val) ->
      $scope.showHide = if val then 'HIDE' else 'SHOW'

    $scope.$on 'cycle:number:updated', (e, num) ->
      $scope.maxCycle = num

    getExperiment = ->
      Experiment.get(id: $stateParams.id).then (data) ->
        $scope.exp = data.experiment
        if !data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'NOT_STARTED'
          $scope.runStatus = 'Not run yet.'
        if data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'RUNNING'
          $scope.runStatus = 'Currently running.'
        if data.experiment.started_at and data.experiment.completed_at
          $scope.status = 'COMPLETED'
          $scope.runStatus = 'Run at:'

        $scope.maxCycle = AmplificationChartHelper.getMaxExperimentCycle data.experiment

    getExperiment()

    $rootScope.$on 'sidemenu:toggle', ->
      if $scope.showProperties and angular.element('.sidemenu').width() > 100
        $scope.showProperties = false

    $scope.$on 'status:data:updated', (e, data, oldData) ->
      #data.lid.open = true
      $scope.lidOpen = data?.lid?.open
      state = data?.experiment_controller?.machine?.state
      oldState = oldData?.experiment_controller?.machine?.state
      getExperiment() if state isnt oldState

])
