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
      $scope.showMessageServerSide(alerts.internalServerError);
    });

    $scope.showMessageServerSide = function(message) {

      $scope.warningMessage = message;
      $scope.modal = $uibModal.open({
        scope: $scope,
        templateUrl: 'app/views/modal-error-warning.html',
        windowClass: 'small-modal',
        //controller: this,
        // This is tricky , we used it here so that,
        //Custom size of this modal doesn't change any other modal in use
      });

    };

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
          //debugger;
          var machine_data = Status.getData();

          if(data.experiment.started_at) {
            $scope.exp_completed = true;
          }
          /*if(data.experiment.completed_at && data.experiment.completion_status) {
            $scope.exp_completed = true;
          } else if(data.experiment.started_at && ! data.experiment.completed_at) {
            $scope.exp_completed = true;
            /*if(machine_data.experiment_controller.machine && machine_data.experiment_controller.machine.state === 'idle') {
              $scope.exp_completed = true;
            }

            if(machine_data.experiment_controller.machine && machine_data.experiment_controller.machine.state !== 'idle') {
              if(machine_data.experiment_controller.experiment.id === $stateParams.id) {
                $scope.exp_completed = true;
              }
            }
          }*/



          //console.log("getData", Status.getData(), $stateParams);


          //console.log("BINGOOOOO", $rootScope);
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

    $scope.convertToMinute = function(deltaTime) {

      var value = deltaTime.indexOf(":");
      if(value != -1) {
        var hr = deltaTime.substr(0, value);
        var min = deltaTime.substr(value + 1);

        if(isNaN(hr) || isNaN(min)) {
          deltaTime = null;
          var warningMessage1 = alerts.nonDigit;
          $scope.showMessage(warningMessage1);
          return false;
        } else {
          deltaTime = (hr * 60) + (min * 1);
          return deltaTime;
        }
      }

      if(isNaN(deltaTime) || !deltaTime) {
        var warningMessage2 = alerts.nonDigit;
        $scope.showMessage(warningMessage2);
        return false;
      } else {
        return parseInt(Math.abs(deltaTime));
      }
    };

    $scope.convertToSeconds = function(durationString) {

      var durationArray = durationString.split(":");

      if(durationArray.length > 1) {
        var tt = [0, 0, 0], len = durationArray.length, HH = 0, MM = 0, SS = 0;

        if(durationArray[len - 1] && Number(durationArray[len - 1]) < 60) {
          SS = Number(durationArray[len - 1]);
        } else {
          console.log("Plz verify seconds");
          return false;
        }

        if(durationArray[len - 2] && Number(durationArray[len - 2]) < 60) {
          MM = Number(durationArray[len - 2]);
        } else {
          console.log("Plz verify Minutes");
          return false;
        }

        if(durationArray[len - 3]) {

          if(Number(durationArray[len - 3]) < 9999) {
            HH = Number(durationArray[len - 3]);
          } else {
            console.log("Plz verify Hours we support upto 9999");
            return false;
          }
        }

        return (HH * 3600) + (MM * 60) + SS;

      } else if(!isNaN(durationString)) {
        return durationString;
      } else {
        var warningMessage1 = alerts.nonDigit;
        $scope.showMessage(warningMessage1);
      }
    };

    $scope.timeFormating = function(reading) {

      var mins = Number(reading);
      var negative = (mins < 0) ? "-" : "";

      reading = Math.abs(reading);

      var hour = Math.floor(reading / 60);
      hour = (hour < 10) ? "0" + hour : hour;

      var min = reading % 60;
      min = (min < 10) ? "0" + min : min;

      return negative + hour + ":" + min;
    };

    $scope.newTimeFormatting = function(reading) {

      var negative = (reading < 0) ? "-" : "";
      reading = Math.abs(reading);

      var hour = Math.floor(reading / 3600);
      hour = (hour < 10) ? "0" + hour : hour;

      var noMin = reading % 3600;

      var min = Math.floor(noMin / 60);
      min = (min < 10) ? "0" + min : min;

      var noSec = noMin % 60;
      noSec = (noSec < 10) ? "0" + noSec : noSec;

      if(hour === "00") {
        return negative + min + ":" + noSec;
      }
      return negative + hour + ":" + min + ":" + noSec;
    };

    $scope.showMessage = function(message) {

      $scope.warningMessage = message;
      $scope.modal = $uibModal.open({
        scope: $scope,
        templateUrl: 'app/views/modal-warning.html',
        windowClass: 'small-modal'
        // This is tricky , we used it here so that,
        //Custom size of this modal doesn't change any other modal in use
      });
    };

    $scope.tryVal = function() {
      console.log("all okay");
    };
  }
]);
