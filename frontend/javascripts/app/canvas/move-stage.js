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

angular.module("canvasApp").factory('moveStageRect', [
  'ExperimentLoader',

  function(ExperimentLoader) {

    return {

      getMoveStageRect: function(me) {

        this.currentHit = 0;
        this.currentDrop = null;
        this.startPosition = 0;
        this.endPosition = 0;

        var smallCircle = new fabric.Circle({
          radius: 6, fill: '#FFB300', stroke: "black", strokeWidth: 3, selectable: false,
          left: 48, top: 298, originX: 'center', originY: 'center',
        });

        var smallCircleTop = new fabric.Circle({
          radius: 5, fill: 'black', selectable: false, left: 48, top: 13, originX: 'center', originY: 'center',
        });

        var temperatureText = new fabric.Text(
          "20º", {
            fill: 'black',  fontSize: 20, selectable: false, originX: 'left', originY: 'top',
            top: 9, left: 1, fontFamily: "dinot-bold"
          }
        );

        var holdTimeText = new fabric.Text(
          "0:05", {
            fill: 'black',  fontSize: 20, selectable: false, originX: 'left', originY: 'top',
            top: 9, left: 59, fontFamily: "dinot"
          }
        );

        var indexText = new fabric.Text(
          "02", {
            fill: 'black',  fontSize: 16, selectable: false, originX: 'left', originY: 'top',
            top: 30, left: 17, fontFamily: "dinot-bold"
          }
        );

        var placeText= new fabric.Text(
          "01/01", {
            fill: 'black',  fontSize: 16, selectable: false, originX: 'left', originY: 'top',
            top: 30, left: 42, fontFamily: "dinot"
          }
        );

        var verticalLine = new fabric.Line([0, 0, 0, 276],{
          left: 47,
          top: 58,
          stroke: 'black',
          strokeWidth: 2,
          originX: 'left', originY: 'top',
        });

        var rect = new fabric.Rect({
          fill: 'white', width: 135, left: 0, height: 58, selectable: false, name: "step", me: this, rx: 1,
        });

        var coverRect = new fabric.Rect({
          fill: null, width: 135, left: 0, top: 0, height: 372, selectable: false, me: this, rx: 1,
        });

        /*me.imageobjects["drag-footer-image.png"].originX = "left";
        me.imageobjects["drag-footer-image.png"].originY = "top";
        me.imageobjects["drag-footer-image.png"].top = 52;
        me.imageobjects["drag-footer-image.png"].left = 9;*/

        indicatorRectangle = new fabric.Group([
          rect, temperatureText, holdTimeText, indexText, placeText,
          //me.imageobjects["drag-footer-image.png"],

        ],
          {
            originX: "left", originY: "top", left: 0, top: 0, height: 72, selectable: true, lockMovementY: true, hasControls: false,
            visible: true, hasBorders: false, name: "dragStepGroup"
          }
        );

        this.indicator = new fabric.Group([coverRect, indicatorRectangle, verticalLine, smallCircle, smallCircleTop], {
          originX: "left", originY: "top", left: 38, top: 0, height: 372, width: 135, selectable: true,
          lockMovementY: true, hasControls: false, visible: false, hasBorders: false, name: "dragStageGroup"
        });

        return this.indicator;
      },

    };
  }
]
);
