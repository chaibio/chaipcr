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
window.ChaiBioTech.ngApp.controller 'CreateExperimentModalCtrl', [
  '$scope'
  'Experiment'
  ($scope, Experiment) ->
    $scope.newExperimentName = 'New Experiment'
    $scope.focused = false
    $scope.loading = false

    $scope.focus = ->
      $scope.focused = true
      $scope.submitted = false
      if $scope.newExperimentName is 'New Experiment'
        $scope.newExperimentName = ''

    $scope.unfocus = ->
      if $scope.newExperimentName is '' or !$scope.newExperimentName
        $scope.focused = false
        $scope.newExperimentName = 'New Experiment'

    $scope.submit = (expName) ->
      $scope.submitted = true
      if $scope.form.$valid and $scope.newExperimentName isnt 'New Experiment'
        # $scope.$close expName

        exp = new Experiment
          experiment:
            name: expName || 'New Experiment'
            protocol: {}

        $scope.loading = true

        exp.$save()
        .then (data) =>
          $scope.$close data.experiment
        , (err) ->
          console.log err
          $scope.error = true
          $scope.loading = false

]