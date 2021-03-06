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

window.ChaiBioTech.ngApp.directive('stageTypePopup', [
  'ExperimentLoader',
  '$timeout',
  'canvas',
  'popupStatus',
  'addStageService',
  function(ExperimentLoader, $timeout, canvas, popupStatus, addStageService) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/stage-type-popup.html',

      scope: false,

      link: function(scope, elem, attr) {
        scope.addStage = function(type) {

          if(! scope.infiniteHold) {
            ExperimentLoader.addStage(scope, type)
              .then(function(data) {
                console.log("added", data);
                scope.actionPopup = false;
                addStageService.addNewStage(data, scope.fabricStep.parentStage);
              });
          }
        };
      }
    };
  }
]);
