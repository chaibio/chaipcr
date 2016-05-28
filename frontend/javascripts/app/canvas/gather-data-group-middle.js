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

angular.module("canvasApp").factory('gatherDataGroupMiddle', [
  function() {
    return function(objs, parent) {

      var midPointY = null;

      if(parent.previous) {
        midPointY = (parent.top) - 20;
      }

      return new fabric.Group(objs, {
        left: parent.left,
        top: midPointY || 230,
        me: this,
        selectable: false,
        name: "gatherDataGroupMiddle",
        originX: "center",
        originY: "center",
        visible: false
      });
    };
  }
]);
