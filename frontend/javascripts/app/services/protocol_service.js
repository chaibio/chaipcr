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

window.ChaiBioTech.ngApp.service('ExperimentLoader', [
  'Experiment',
  '$q',
  '$stateParams',
  '$rootScope',
  '$http',
  function(Experiment, $q, $stateParams, $rootScope, $http) {

    this.protocol = {};
    this.index = 0;

    this.getExperiment = function() {

      var delay, that = this;
      delay = $q.defer();
      
      var del = Experiment.get({'id': $stateParams.id});
      
      del.then(function(data) {
        
        that.protocol = data.experiment;
        //$rootScope.$broadcast("dataLoaded");
        delay.resolve(data);
      })
      .catch(function() {
        delay.reject('Cant bring the data');
      });

      return delay.promise;
    };

    this.loadFirstStages = function() {

      return this.protocol.protocol.stages[0].stage;
    };

    this.loadFirstStep = function() {
      return this.protocol.protocol.stages[0].stage.steps[0].step;
    };

    this.getNew = function() {

      return this.protocol.protocol.stages[1].stage;
    };

    this.update = function(url, dataToBeSend, delay) {

      if(dataToBeSend.name !== null) {
        $http.put(url, dataToBeSend)
          .success(function(data) {
            delay.resolve(data);
          })
          .error(function(data) {
            // we need to do something so that it shows correct error message.
            console.log(data);
            delay.reject(data);
          });

        return delay.promise;
      }
    };

    /********************Stage API Methods************************/

    this.addStage = function($scope, type) {

      var id = $scope.stage.id,
      dataToBeSend = {
        "prev_id": id,
        "stage": {
          'stage_type': type
        }
      },
      url = "/protocols/" + $scope.protocol.protocol.id + "/stages",
      delay = $q.defer();

      $http.post(url, dataToBeSend)
      .success(function(data) {
        delay.resolve(data);
      })
      .error(function(data) {
        delay.reject(data);
      });

      return delay.promise;
    };

    this.moveStage = function(id, prev_id) {

      var dataToBeSend = {'prev_id': prev_id},
      url = "/stages/" + id + "/move";
      delay = $q.defer();

      $http.post(url, dataToBeSend)
        .success(function(data) {
          delay.resolve(data);
        })
        .error(function(data) {
          delay.reject(data);
        });

      return delay.promise;
    };

    this.saveCycle = function($scope) {

      var dataToBeSend = {'stage': {'num_cycles': $scope.stage.num_cycles}},
      url = "/stages/"+ $scope.stage.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);

    };

    this.changeStartOnCycle = function($scope) {

      var dataToBeSend = {'stage': {'auto_delta_start_cycle': $scope.stage.auto_delta_start_cycle}},
      url = "/stages/"+ $scope.stage.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);

    };

    this.updateAutoDelata = function($scope) {

      var dataToBeSend = {'stage': {'auto_delta': $scope.stage.auto_delta}},
      url = "/stages/"+ $scope.stage.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);

    };
    /********************Step API Methods************************/

    this.moveStep = function(id, prev_id, stage_id) {

      var dataToBeSend = {'prev_id': prev_id, 'stage_id': stage_id },
      url = "/steps/" + id + "/move";
      delay = $q.defer();

      $http.post(url, dataToBeSend)
        .success(function(data) {
          delay.resolve(data);
        })
        .error(function(data) {
          delay.reject(data);
        });

      return delay.promise;
    };

    this.changeTemperature = function($scope) {

      var dataToBeSend = {'step':{'temperature': $scope.step.temperature}},
      url = "/steps/" + $scope.step.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);

    };

    this.addStep = function($scope) {

      var stageId = $scope.stage.id,
      dataToBeSend = {"prev_id": $scope.step.id},
      delay = $q.defer(),
      url = "/stages/"+ stageId +"/steps";

      $http.post(url, dataToBeSend)
        .success(function(data) {
          delay.resolve(data);
        })
        .error(function(data) {
          delay.reject(data);
        });

      return delay.promise;
    };

    this.deleteStep = function($scope) {

      var that = this,
      url = "/steps/" + $scope.step.id,
      delay = $q.defer();

      $http.delete(url)
        .success(function(data) {
          delay.resolve(data);
        })
        .error(function(data) {
          delay.reject(data);
        }
      );
      return delay.promise;
    };

    this.gatherDuringStep = function($scope) {

      var that = this,
      dataToBeSend = {'step': {'collect_data': $scope.step.collect_data}},
      url = "/steps/" + $scope.step.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);

    };

    this.gatherDataDuringRamp = function($scope) {

      var dataToBeSend = {'ramp': {'collect_data': $scope.step.ramp.collect_data}},
      url = "/ramps/" + $scope.step.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);

    };

    this.changeRampSpeed = function($scope) {

      var dataToBeSend = {'ramp': {'rate': $scope.step.ramp.rate}},
      url = "/ramps/" + $scope.step.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);

    };

    this.changeHoldDuration = function($scope) {

      var dataToBeSend = {'step': {'hold_time': $scope.step.hold_time}},
      url = "/steps/" + $scope.step.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);

    };

    this.saveName = function($scope) {

      var dataToBeSend = {'step': {'name': $scope.step.name}},
      url = "/steps/" + $scope.step.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);
    };

    this.changeDeltaTemperature = function($scope) {

      var dataToBeSend = {'step': {'delta_temperature': $scope.step.delta_temperature}},
      url = "/steps/" + $scope.step.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);
    };

    this.changeDeltaTime = function($scope) {
      //console.log("I am here", $scope);
      var dataToBeSend = {'step': {'delta_duration_s': $scope.step.delta_duration_s}},
      url = "/steps/" + $scope.step.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);
    };

    this.changePause = function($scope) {

      console.log($scope.step.pause);
      var dataToBeSend = {'step': {'pause': $scope.step.pause}},
      url = "/steps/" + $scope.step.id,
      delay = $q.defer();
      return this.update(url, dataToBeSend, delay);
    };
  }
]);
