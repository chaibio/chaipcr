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

angular.module("canvasApp").factory('htmlEvents', [
  'previouslyHoverd',
  'popupStatus',
  'editMode',

  function(previouslyHoverd, popupStatus, editMode) {

    var me = this, reference, kanvas;
   
    this.init = function(C, that) {
      reference = that;
      kanvas = C;

      angular.element('body').click(me.manageClcikOnBody);

      angular.element('.canvas-container, .canvasClass').mouseleave(me.mouseLeaveEventHandler);

      angular.element('.canvas-containing').click(me.manageClickOnCanvasContaining);

    };

    this.manageClcikOnBody = function(evt) {

      if (popupStatus.popupStatusAddStage && evt.target.id != "add-stage") {
          angular.element('#add-stage').click();
      }
    };

    this.manageClickOnCanvasContaining = function(evt) {

      if (evt.target == evt.currentTarget) {
        reference.setSummaryMode();
      }
    };

    this.mouseLeaveEventHandler = function() {
        if (kanvas.editStageStatus === false) {
            if (previouslyHoverd.step) {
              previouslyHoverd.step.closeImage.setOpacity(false);
            }
            kanvas.canvas.renderAll();
        }

        // if (editMode.tempActive === true) {
        //   editMode.currentActiveTemp.fire('text:editing:exited');
        // }

        // if (editMode.holdActive === true) {
        //   editMode.currentActiveHold.fire('text:editing:exited');
        // }
    };

    return this;
  }
]);
