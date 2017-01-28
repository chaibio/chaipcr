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

angular.module("canvasApp").factory('stepDataGroup', [
  function() {
    return function(dataArray, parent) {
      var rec = new fabric.Rect({
        width: 105,
        height: 20,
        fill: 'green',
        opacity: 0.1,
        top: parent.top + 22,
        left: parent.left + 35,
        originX: 'center',
        originY: "center",
        hasBorder: false,
        hasControls: false,
      });

      dataArray.push(rec);
      
      return new fabric.Group(dataArray, {
        top: parent.top + 48,
        left: parent.left + 60,
        originX: "center",
        originY: "center",
        selectable: false,
        name: "stepDataGroup",
        evented: true,
        parentCircle: parent,
        //backgroundColor: 'black'
      });
    };
  }
]);
