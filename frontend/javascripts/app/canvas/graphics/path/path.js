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

angular.module("canvasApp").factory('path', [
  'constants',
  function(constants) {
    return function(parent) {

      var x1 = parent.left + (constants.stepWidth / 2), y1 = parent.top,
      x2 = parent.next.left + (constants.stepWidth / 2), y2 = parent.next.top;

      var midPointX = (x1 + x2) / 2,
      midPointY = (y1 + y2) / 2;

      this.controlDistance = constants.controlDistance;

      this.pathText = 'm '+ x1 +' ' + y1 +' Q '+ (x1 + this.controlDistance) +', '+ y1 +', ' + midPointX +', '+ midPointY +' Q '+ (x2 - this.controlDistance) +', '+ y2 +', '+ x2 +', '+ y2 +'';

      this.curve = new fabric.Path(this.pathText, {
        strokeWidth: 4, fill: '', stroke: '#ffd100', selectable: false, originX: "center", originY: "center", me: parent,
        name: "path", evented: false
      });
      /*************************************************************************/
      // this pointer in circle represents the bottom portion because we are returning the path , not this...!!
      this.curve.nextOne = function(left, top) {

        var endPointX, endPointY, midPointX, midPointY;
        /*
          Remember there is a path array in curve [fabric.path], This file is returning a path object, and that
          contains path array.
        */
        this.path[0][1] = left;
        this.path[0][2] = top;
        // Calculating the mid point of the line at the right side of the circle
        // Remeber take the point which is static at the other side
        endPointX = this.path[2][3];
        endPointY = this.path[2][4];

        midPointX = (left + endPointX) / 2;
        midPointY = (top + endPointY) / 2;

        this.path[1][1] = left + constants.controlDistance;
        this.path[1][2] = top;
        // Mid point
        this.path[1][3] = midPointX;
        this.path[1][4] = midPointY;

        this.path[2][1] = endPointX - constants.controlDistance;
        this.path[2][2] = endPointY;

        return midPointY;
      };

      this.curve.previousOne = function(left, top) {

        var endPointX, endPointY, midPointX, midPointY;

        this.path[2][3] = left;
        this.path[2][4] = top;

        endPointX = this.path[0][1];
        endPointY = this.path[0][2];

        midPointX = (left + endPointX) / 2;
        midPointY = (top + endPointY) / 2;

        this.path[2][1] = left - constants.controlDistance;
        this.path[2][2] = top;

        this.path[1][3] = midPointX;
        this.path[1][4] = midPointY;

        this.path[1][1] = endPointX + constants.controlDistance;
        this.path[1][2] = endPointY;

        return midPointY;
      };
      /*************************************************************************/
      return this.curve;
    };
  }
]);
