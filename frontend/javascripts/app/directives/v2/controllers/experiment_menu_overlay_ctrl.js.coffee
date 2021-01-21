###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
window.ChaiBioTech.ngApp.controller('ExperimentMenuOverlayCtrl', [
  '$scope'
  '$stateParams'
  'Experiment'
  '$state'
  'AmplificationChartHelper'
  'Status',
  '$timeout'
  '$rootScope'
  '$http'
  '$window'
  ($scope, $stateParams, Experiment, $state, AmplificationChartHelper, Status, $timeout, $rootScope, $http, $window) ->
    $scope.params = $stateParams
    $scope.stateInfo = $state.current
    $scope.lidOpen = false
    $scope.showProperties = false
    $scope.status = null
    $scope.exp = null
    $scope.well_layout = null
    $scope.exp_type = ''
    $scope.errorExport = false
    $scope.exporting = false
    $scope.isIdle = false
    $scope.runningExpId = 0

    $scope.confirmStatus = false
    $scope.isConfirmDelete = false
    $scope.isConfirmCancel = false

    isInit = true

    $scope.$on 'runReady:true', ->
      $scope.confirmStatus = true

    angular.element('body').click (e) ->
      if $scope.confirmStatus == true and e.target.innerHTML != 'Run Experiment'
        $rootScope.$broadcast 'runReady:false'
        $scope.confirmStatus = false
      if $scope.isConfirmDelete == true and e.target.innerHTML != 'Delete'
        $scope.isConfirmDelete = false
      if $scope.isConfirmCancel == true and e.target.innerHTML != 'Cancel'
        $scope.isConfirmCancel = false

    $scope.setConfirmDelete = (isConfirm) ->
      $scope.isConfirmDelete = isConfirm

    $scope.getConfirmDelete = () ->
      $scope.isConfirmDelete

    $scope.setConfirmCancel = (isConfirm) ->
      $scope.isConfirmCancel = isConfirm

    $scope.getConfirmCancel = () ->
      $scope.isConfirmCancel

    $scope.deleteExperiment = ->
      #exp = new Experiment id: $stateParams.id
      Experiment.delete($stateParams.id)
      .then ->
        $state.go 'home'

    callAtTimeout = ->
      $scope.exportExperiment()

    $scope.exportExperiment = ->
      $scope.exporting = true
      $scope.errorExport = false
      id = $stateParams.id
      url = "/experiments/"+$stateParams.id+"/export"
      isChrome = !!window.chrome
      if isChrome && !(/Edge/.test(navigator.userAgent))
        $http.get(url, responseType: 'arraybuffer')
        .success (resp,status) =>
          if status == 202
            $timeout callAtTimeout, 500
          console.log status
          if status!= 202
            blob = new Blob([resp], type: 'application/octet-stream')
            link = document.createElement('a')
            link.href = window.URL.createObjectURL(blob)
            link.download = 'exportExperiment.zip'
            link.click()
            $scope.exporting = false
        .error (resp,status) =>
          console.log status
          if status == 503
            $timeout callAtTimeout, 500
          else
            $scope.exporting = false
            $scope.errorExport = true
      else
        $http.head(url)
        .success (resp,status) =>
          if status == 202
            $timeout callAtTimeout, 500
          console.log status
          if status!= 202
            $window.location.assign url
            $scope.exporting = false
        .error (resp,status) =>
          console.log status
          if status == 503
            $timeout callAtTimeout, 500
          else
            $scope.exporting = false
            $scope.errorExport = true

    $scope.$watch (()->
      $scope.showProperties), (val) ->
        $scope.showHide = if val then 'HIDE' else 'SHOW'

    $scope.$on 'cycle:number:updated', (e, num) ->
      $scope.maxCycle = num

    $scope.getExperiment = ->
      Experiment.get(id: $stateParams.id).then (data) ->
        $scope.exp = data.experiment
        $scope.exp_type = $scope.exp.type
        if !data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'NOT_STARTED'
          $scope.runStatus = 'Not run yet.'
        if data.experiment.started_at and !data.experiment.completed_at
          if !$scope.isIdle and (parseInt($scope.runningExpId) is parseInt($scope.exp.id))
            $scope.status = 'RUNNING'
            $scope.runStatus = ''
          else if isInit
            $scope.status = ''
            $scope.runStatus = ''            
          else
            $scope.status = 'COMPLETED'
            $scope.runStatus = 'Run on:'
        if data.experiment.started_at and data.experiment.completed_at
          $scope.status = 'COMPLETED'
          $scope.runStatus = 'Run on:'

        $scope.maxCycle = AmplificationChartHelper.getMaxExperimentCycle data.experiment

    $scope.getWellLayout = ->
      Experiment.getWellLayout($stateParams.id).then (data) ->
        $scope.well_layout = data.data

    $scope.hasStandardTarget = ->
      if $scope.well_layout        
        std_wells = _.filter $scope.well_layout, (item) ->
          if item.targets
            std_targets = _.filter item.targets, (target) ->
              target.well_type == 'standard'
            return std_targets.length > 0
        return std_wells.length > 0
      return false

    $scope.getExperiment()
    $scope.getWellLayout()

    $scope.goTestKit = (route)->
      if $scope.exp
        switch $scope.exp.guid
          when "chai_coronavirus_env_kit"
            $state.go('coronavirus-env.' + route, id: $scope.exp.id)
          when "chai_covid19_surv_kit"
            $state.go('covid19-surv.' + route, id: $scope.exp.id)
          when "pika_4e_kit", "pika_4e_lp_identification_kit"
            $state.go('pika_test.' + route, id: $scope.exp.id)

    $scope.hasMeltCurve = ->
      return if $scope.exp then Experiment.hasMeltCurve($scope.exp) else false

    $scope.hasAmplification = ->
      return if $scope.exp then Experiment.hasAmplificationCurve($scope.exp) else false

    $scope.hasStandardCurve = ->
      return if $scope.exp then Experiment.hasStandardCurve($scope.exp) and $scope.hasStandardTarget() else false

    $scope.cancelExperiment = ->
      Experiment.stopExperiment($stateParams.id).then (data) ->
        $state.go 'home'

    $scope.openProperties = (prop) ->
      $scope.showProperties = prop

    $rootScope.$on 'sidemenu:toggle', ->
      $scope.errorExport = false
      if $scope.showProperties and angular.element('.sidemenu').width() > 100
        $scope.showProperties = false
        #$scope.errorExport = false

    $scope.$on 'status:data:updated', (e, data, oldData) ->
      $scope.lidOpen = if data?.optics?.lid_open == "true" then true else false
      state = data?.experiment_controller?.machine?.state
      oldState = oldData?.experiment_controller?.machine?.state
      return if !data
      return if !data.experiment_controller
      $scope.isIdle = if data.experiment_controller.machine.state == 'idle' then true else false
      $scope.runningExpId = data.experiment_controller.experiment?.id

      if isInit
        $scope.getExperiment()
        isInit = false
      else
        $scope.getExperiment() if (state isnt oldState) or (!$scope.isIdle and $scope.status isnt 'RUNNING' and $scope.runningExpId is $stateParams.id)
])
