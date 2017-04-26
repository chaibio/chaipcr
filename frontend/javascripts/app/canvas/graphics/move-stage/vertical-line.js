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

angular.module("canvasApp").factory('verticalLine', [
    function() {
        return function() {
            var smallCircle = new fabric.Circle({
                radius: 6, fill: 'white', stroke: "black", strokeWidth: 2, selectable: false,
                left: 69, top: 390, originX: 'center', originY: 'center',
            });

            var smallCircleTop = new fabric.Circle({
                fill: '#FFB300', radius: 6, strokeWidth: 3, selectable: false, stroke: "black",
                left: 69, top: 64, originX: 'center', originY: 'center'
            });

            var verticalLine = new fabric.Line([0, 0, 0, 336],{
                left: 68, top: 58, stroke: 'black', strokeWidth: 2, originX: 'left', originY: 'top'
            });

            var vertical = new fabric.Group([verticalLine, smallCircleTop, smallCircle], {
                originX: "left", originY: "top", left: 62, top: 56, selectable: true,
                lockMovementY: true, hasControls: false, hasBorders: false, name: "vertica", visible: false
            });
            
            return vertical;
        };
    }
]);