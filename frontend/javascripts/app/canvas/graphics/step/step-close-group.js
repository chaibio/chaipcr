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

 angular.module('canvasApp').factory('closeGroup', [
   'Group',
   'closeCircle',
   'closeLine',
   function(Group, closeCircle, closeLine) {
     return function(step) {

       step.newCloseCircle = new closeCircle();
       step.newCloseLine1 = new closeLine();
       step.newCloseLine2 = new closeLine(
         {
             stroke: 'rgb(166, 122, 40)',
             angle: 90,
             originX: 'center',
             originY: 'center',
           }
       );

       var opacity = (step.parentStage.parent.editStageStatus) ? 1 : 0;
       var properties = {
         originX: "center", originY: "center", left: step.left + 116, top: 86, hasBorders: false, hasControls: false,
         lockMovementY: true, lockMovementX: true, parent: step, opacity: opacity, name: 'deleteStepButton', me: step
       };
       
       return Group.create([step.newCloseCircle, step.newCloseLine1, step.newCloseLine2], properties);
     };
   }
 ]);
