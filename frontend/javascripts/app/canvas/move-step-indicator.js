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

angular.module("canvasApp").factory('moveStepIndicator', [
    function() {
        return function(me) {
            
            var stageName = new fabric.Text(
                "STAGE 2", {
                    fill: 'black',  fontSize: 12, selectable: false, originX: 'left', originY: 'top',
                    top: 15, left: 35, fontFamily: "dinot-bold"
                }
                );

            var stageType = new fabric.Text(
            "HOLDING", {
                fill: 'black',  fontSize: 12, selectable: false, originX: 'left', originY: 'top',
                top: 30, left: 35, fontFamily: "dinot-regular"
            }
            );
        
            var rect = new fabric.Rect({
                fill: 'white', width: 135, left: 0, height: 58, selectable: false, name: "step", me: this, rx: 1,
            });

            var coverRect = new fabric.Rect({
                fill: null, width: 135, left: 0, top: 0, height: 372, selectable: false, me: this, rx: 1,
            });

            me.imageobjects["drag-stage-image.png"].originX = "left";
            me.imageobjects["drag-stage-image.png"].originY = "top";
            me.imageobjects["drag-stage-image.png"].top = 15;
            me.imageobjects["drag-stage-image.png"].left = 14;

            var indicatorRectangle = new fabric.Group([
                rect, stageName, stageType,
                me.imageobjects["drag-stage-image.png"],
                ],
                {
                    originX: "left", originY: "top", left: 0, top: 0, height: 72, selectable: true, lockMovementY: true, hasControls: false,
                    visible: true, hasBorders: false, name: "dragStageRect"
                }
            );

            var indicator = new fabric.Group([coverRect, indicatorRectangle], {
            originX: "left", originY: "top", left: 38, top: 0, height: 372, width: 135, selectable: true,
            lockMovementY: true, hasControls: false, visible: false, hasBorders: false, name: "dragStageGroup"
            });
            indicator.stageName = stageName;
            indicator.stageType = stageType;
            return indicator;
        };
    }
]);