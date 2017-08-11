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

angular.module("canvasApp").service('stageEvents',[
  'stepGraphics',
  'stageGraphics',
  function(stepGraphics, stageGraphics) {

    var that = this;
    this.changeDeltaText = function($scope, C) {

      var stage = $scope.fabricStep.parentStage;
      if(stage.model.stage_type === "cycling" && ! stage.parent.editStageStatus) {
        stage.childSteps.forEach(function(step, index) {
          stepGraphics.autoDeltaDetails.call(step);
        });
      }
    };

    this.init = function($scope, canvas, C) {

      $scope.$watch('stage.num_cycles', function(newVal, oldVal) {

        var stage = $scope.fabricStep.parentStage;
        stage.stageHeader();
        canvas.renderAll();
      });

      $scope.$watch('stage.auto_delta', function(newVal, oldVal) {

        that.changeDeltaText($scope);
        canvas.renderAll();
      });

      $scope.$watch('stage.auto_delta_start_cycle', function(newVal, oldVal) {

        that.changeDeltaText($scope, C);
        canvas.renderAll();
      });


    };
  }
]);
