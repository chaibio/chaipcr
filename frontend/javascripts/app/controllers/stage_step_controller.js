/*
 * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

window.ChaiBioTech.ngApp.controller('StageStepCtrl', [
  '$scope',
  'ExperimentLoader',
  'canvas',
  '$uibModal',
  'alerts',
  'expName',
  '$rootScope',
  '$window',
  function($scope, ExperimentLoader, canvas, $uibModal, alerts, expName, $rootScope, $window) {

    var that = this;
    $scope.stage = {};
    $scope.step = {};
    $scope.exp_completed = false;

    $scope.$on("expName:Updated", function() {
      $scope.protocol.name = expName.name;
    });

    $scope.$watch("selected", function() {
      //console.log("lets change val");
    });

    $rootScope.$on('event:error-server', function() {
      // alerts.showMessage(alerts.internalServerError, $scope, 'app/views/modal-error-warning.html');
    });

    $rootScope.$on('alerts.nonDigit', function() {
      alerts.showMessage(alerts.nonDigit, $scope);
    });

    $scope.reload = function() {
      $window.location.reload();
    };


    $scope.initiate = function() {

      ExperimentLoader.getExperiment()
        .then(function(data) {
          //data.experiment.completed_at = data.experiment.completion_status = true;
          $scope.protocol = data.experiment;
          $scope.stage = ExperimentLoader.loadFirstStages();
          $scope.step = ExperimentLoader.loadFirstStep();

          $scope.summaryMode = false;
          $scope.editStageMode = false;
          $scope.showScrollbar = false;
          $scope.scrollWidth = 0;
          $scope.scrollLeft = 0;
          $scope.$broadcast("dataLoaded");

          if(data.experiment.started_at) {
            $scope.exp_completed = true;
          }

          canvas.init($scope);
        });
    };

    $scope.initiate();

    $scope.applyValuesFromOutSide = function(circle) {
      // when the event or function call is initiated from non anular part of the app ... !!
      $scope.$apply(function() {
        $scope.step = circle.parent.model;
        $scope.stage = circle.parent.parentStage.model;
        $scope.fabricStep = circle.parent;
      });

    };

    $scope.applyValues = function(circle) {

      $scope.step = circle.parent.model;
      $scope.stage = circle.parent.parentStage.model;
      $scope.fabricStep = circle.parent;
    };
  }
]);
