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

angular.module("canvasApp").factory('constants', [
  function() {
    var originalStepHeight = 200, tempBarHeight = 18;
    return {
      "stepHeight": originalStepHeight - tempBarHeight,
      "stepUnitMovement": (originalStepHeight - tempBarHeight) / 100, //No more used
      "stepWidth": 128,
      "tempBarWidth": 45,
      "tempBarHeight": tempBarHeight,
      "beginningTemp": 25,
      "originalStepHeight": originalStepHeight,
      "rad2deg": 180 / Math.PI,
      "controlDistance": 50,
      "canvasSpacingFrontAndRear": 33,
      "newStageOffset": 8,
      "additionalWidth": 2
    };
  }
]);
