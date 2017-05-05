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

angular.module("canvasApp").factory('moveStageIndicator', [
    'moveStageName',
    'moveStageType',
    'moveStageRectangle',
    'moveStageCoverRect',
    'moveStageIndicatorRectangleGroup',
    'moveStageIndicatorGroup',
    function(moveStageName, moveStageType, moveStageRectangle, moveStageCoverRect, moveStageIndicatorRectangleGroup, moveStageIndicatorGroup) {
        return function(me) {
            
            var stageName = new moveStageName();

            var stageType = new moveStageType();
        
            var rect = new moveStageRectangle();

            var coverRect = new moveStageCoverRect();
            
            var indicatorRectangleGroup;
            if(me.imageobjects) {
                me.imageobjects["drag-stage-image.png"].originX = "left";
                me.imageobjects["drag-stage-image.png"].originY = "top";
                me.imageobjects["drag-stage-image.png"].top = 15;
                me.imageobjects["drag-stage-image.png"].left = 14;

                indicatorRectangleGroup = new moveStageIndicatorRectangleGroup(
                    [
                        rect, stageName, stageType, me.imageobjects["drag-stage-image.png"]
                    ]
                );
            } else {
                indicatorRectangleGroup = new moveStageIndicatorRectangleGroup(
                    [
                        rect, stageName, stageType
                    ]
                );
            }
            
            var indicator = new moveStageIndicatorGroup([
                coverRect,
                indicatorRectangleGroup
            ]);

            indicator.stageName = stageName; // For easy reference;
            indicator.stageType = stageType;
            
            return indicator;
        };
    }
]);