angular.module('dynexp.pika_test').controller 'ExpNameEditorCtrl', [
  '$scope'
  'focus'
  'Experiment'
  '$stateParams'
  'expName'
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
    $scope.ori_experiment_name = ''

    getData = ->
      Experiment.get(id: $stateParams.id).then (data) ->
        $scope.experiment = data.experiment        
        $scope.experimentOrig = angular.copy data.experiment
        if !data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'NOT_STARTED'
          $scope.runStatus = 'Not run yet.'
        if data.experiment.started_at and !data.experiment.completed_at
          if data.experiment.completion_status
            $scope.status = 'RUNNING'
            $scope.runStatus = 'Currently running.'
          else
            $scope.status = 'COMPLETED'
            $scope.runStatus = 'Run on:'
        if data.experiment.started_at and data.experiment.completed_at
          $scope.status = 'COMPLETED'
          $scope.runStatus = 'Run on:'

    getData()

    $scope.$on 'status:data:updated', (e, data) ->
      if parseInt(data?.experiment_controller?.experiment?.id) is parseInt($stateParams.id) and $scope.experiment
        $scope.experiment.started_at = data.experiment_controller.experiment.started_at
        $scope.experiment.completed_at = data.experiment_controller.experiment.completed_at

    $scope.removeMessages = ->
      $scope.successLid = $scope.successName = null
      $scope.errors = null


    $scope.typeSelected = (type) ->
      $scope.selectedType = type

    $scope.adjustTextHeight = () ->
      $timeout (() ->
        field_width = document.getElementById('exp_name_field').offsetWidth
        angular.element(document.getElementById('exp_name_plat')).css('width', field_width + 'px')
        plat_height = document.getElementById('exp_name_plat').offsetHeight
        angular.element(document.getElementById('exp_name_field')).css('height', (plat_height + 30) + 'px')
        ), 10      
    $scope.focusExpName = ->

      #if $scope.status == "NOT_STARTED"
      plat_height = document.getElementById('exp_name_plat').offsetHeight
      angular.element(document.getElementById('exp_name_field')).css('height', (plat_height + 30) + 'px')
      
      $scope.ori_experiment_name = $scope.experiment.name
      $scope.removeMessages()
      $scope.editExpNameMode = true
      focus('editExpNameMode')
      document.getElementById('exp_name_field').select()

    $scope.cancelExpName = ->      
      $scope.editModeOff()
      $scope.experiment.name = $scope.ori_experiment_name

    $scope.focusLidTemp = ->
      if $scope.status == "NOT_STARTED"
        $scope.removeMessages()
        if $scope.experiment?.started_at
          $scope.errors = "Experiment has been run."
          return

        $scope.editLidTempMode = true
        focus('editLidTempMode')

    $scope.focusNote = ->
        $scope.editNoteMode = true
        focus('editNoteMode')

    $scope.editModeOff = ->
      angular.element(document.getElementById('exp_name_plat')).css('width', '100%')
      $scope.editExpNameMode = false
      $scope.editLidTempMode = false
      $scope.editNoteMode = false

    $scope.saveExperiment = (exp)->
      return if $scope.expForm.$invalid
      promise = Experiment.update({id: $scope.experiment.id}, experiment: $scope.experiment).$promise

      promise.then ->
        $scope.successName = "Experiment name updated."
        $scope.ori_experiment_name = $scope.experiment.name
        expName.updateName($scope.experiment.name)
        $timeout (() ->
          $scope.successName = null
          ), 2000

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig
        $scope.experiment.name = $scope.ori_experiment_name

      promise.finally ->
        $scope.editModeOff()

    $scope.updateNote = () ->
      promise = Experiment.update({id: $scope.experiment.id}, experiment: $scope.experiment).$promise

      promise.then ->
        $scope.successNote = "Experiment notes updated."
        $timeout (() ->
          $scope.successNote = null
          ), 2000

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig

      promise.finally ->
        $scope.editModeOff()


    $scope.updateProtocol = (data, expForm) ->
      if expForm.lidTemp.$invalid
        $scope.experiment.protocol.lid_temperature = $scope.experimentOrig.protocol.lid_temperature
        return

      if data.lid_temperature > 120
        $scope.experiment.protocol.lid_temperature = 120
        data.lid_temperature = 120

      promise = Protocol.update data

      promise.success ->
        $scope.successLid = "Lid temperature updated."
        $timeout (() ->
          $scope.successLid = null
          ), 2000

      promise.catch (resp) ->
        $scope.errors = resp.data.errors
        $scope.experiment = angular.copy $scope.experimentOrig

      promise.finally ->
        $scope.editModeOff()

]
