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
    'moveStepTemperatureText',
    'moveStepHoldTimeText',
    'moveStepIndexText',
    'moveStepPlaceText',
    'moveStepRectangle',
    'moveStepIndicatorRectangleGroup',
    'moveStepIndicatorGroup',
    'dots',
    'Group',
    function(moveStepTemperatureText, moveStepHoldTimeText, moveStepIndexText, moveStepPlaceText, moveStepRectangle,
        moveStepIndicatorRectangleGroup, moveStepIndicatorGroup, dots, Group) {
        return function(me) {
            
            //me.imageobjects["drag-footer-image.png"].originX = "left";
            //me.imageobjects["drag-footer-image.png"].originY = "top";
            //me.imageobjects["drag-footer-image.png"].top = 52;
            //me.imageobjects["drag-footer-image.png"].left = 20;

            var components = dots.stepDots();
            
            components.forEach(function(obj) {
                obj.setFill("black");
            }, this);

            var properties =  {
                originX: "left", originY: "top", left: 16, top: 52, visible: true, lockMovementY: true,
                hasBorders: false, hasControls: false, name: "", parent: null
            };

            var componentsFirstSet = [
                new moveStepRectangle(), 
                new moveStepTemperatureText(), 
                new moveStepHoldTimeText(), 
                new moveStepIndexText(), 
                new moveStepPlaceText(),
                Group.create(components, properties)
            ];
            
            var componentsSecondSet = [
                new moveStepIndicatorRectangleGroup(componentsFirstSet)
            ];

            this.indicator = new moveStepIndicatorGroup(componentsSecondSet);

            this.indicator.temperatureText = componentsFirstSet[1];
            this.indicator.holdTimeText = componentsFirstSet[2];
            this.indicator.indexText = componentsFirstSet[3];
            this.indicator.placeText = componentsFirstSet[4];
            

            return this.indicator;
        };
    }
]);