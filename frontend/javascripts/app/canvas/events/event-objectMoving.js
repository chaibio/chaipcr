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

angular.module("canvasApp").factory('objectMoving', [
  'moveRampLineService',
  function(moveRampLineService) {

    /**************************************
        Here we write what happens when we drag over the canvas.
        here too we look for the target in the event and do the action.
    ***************************************/
    this.init = function(C, $scope, that) {

      var me;
      this.canvas.on('object:moving', function(evt) {

        if(! evt.target) return false;

        switch(evt.target.name) {

          case "controlCircleGroup":
            me = evt.target.me;
            moveRampLineService.manageDrag(evt.target);
            $scope.$apply(function() {
              $scope.step.temperature = me.model.temperature;
            });
          break;

          case "moveStep":

            if(evt.target.left > C.stepMoveLimit) {
              evt.target.setLeft(C.stepMoveLimit);
            } else if(evt.target.left < 20){
              evt.target.setLeft(20);
            } else {
              C.stepIndicator.onTheMove(evt.target);
            }

          break;

          case "moveStage":

            if(evt.target.left < 35) {
              evt.target.setLeft(35);
            } else if(evt.target.left > C.moveLimit) {
              evt.target.setLeft(C.moveLimit);
            } else {
              C.stageIndicator.onTheMove(evt.target);
            }
          break;
        }
      });
    };
    return this;
  }
]);
