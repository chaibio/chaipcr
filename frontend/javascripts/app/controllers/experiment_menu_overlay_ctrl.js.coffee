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
    $scope.lidOpen = false
    $scope.showProperties = false
    $scope.status = null
    $scope.exp = null
    $scope.errorExport = false
    $scope.exporting = false
    $scope.isIdle = false
    $scope.runningExpId = 0

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
        if !data.experiment.started_at and !data.experiment.completed_at
          $scope.status = 'NOT_STARTED'
          $scope.runStatus = 'Not run yet.'
        if data.experiment.started_at and !data.experiment.completed_at
          if !$scope.isIdle and (parseInt($scope.runningExpId) is parseInt($scope.exp.id))
            $scope.status = 'RUNNING'
            $scope.runStatus = 'Currently running.'
          else
            $scope.status = 'COMPLETED'
            $scope.runStatus = 'Run on:'
        if data.experiment.started_at and data.experiment.completed_at
          $scope.status = 'COMPLETED'
          $scope.runStatus = 'Run on:'

        $scope.maxCycle = AmplificationChartHelper.getMaxExperimentCycle data.experiment

    $scope.getExperiment()

    $scope.hasMeltCurve = ->
      return if $scope.exp then Experiment.hasMeltCurve($scope.exp) else false

    $scope.hasAmplification = ->
      return if $scope.exp then Experiment.hasAmplificationCurve($scope.exp) else false

    $scope.hasStandardCurve = ->
      return if $scope.exp then Experiment.hasStandardCurve($scope.exp) else false

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
      $scope.getExperiment() if (state isnt oldState) or (!$scope.isIdle and $scope.status isnt 'RUNNING')
])
