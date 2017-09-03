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

angular.module("canvasApp").factory('circleManager', [
  'path',
  'moveRampLineService',
  function(path, moveRampLineService) {

    this.init = function(kanvas) {

      this.originalCanvas = kanvas;
      this.allStepViews = kanvas.allStepViews;
      this.allCircles = kanvas.allCircles;
      this.findAllCirclesArray = kanvas.findAllCirclesArray;
      this.drawCirclesArray = kanvas.drawCirclesArray;
      this.canvas = kanvas.canvas;
    };

    this.togglePaths = function(toggle) {

      this.originalCanvas.allStepViews.forEach(function(step, index) {
        if(step.circle.curve) {
          step.circle.curve.setVisible(toggle);
        }
      });
    };

    // Instead of removing circle may be we should remove paths
    this.addRampLinesAndCircles = function(circles) {

      this.originalCanvas.allCircles = this.allCircles = circles || this.findAllCircles();
      var limit = this.allCircles.length;

      this.allCircles.forEach(function(circle, index) {

        if(index < (limit - 1)) {
          circle.moveCircle();
          circle.curve = new path(circle);
          this.canvas.add(circle.curve);
        }

        circle.getCircle();
        this.canvas.bringToFront(circle.parent.rampSpeedGroup);
      }, this);

      // We should put an infinity symbol if the last step has infinite hold time.
      this.allCircles[limit - 1].doThingsForLast();
      console.log("All circles are added ....!!");
      return this;
    };

    this.addRampLines = function() {

      var anchorCircle = this.originalCanvas.allStepViews[0].circle;

      var limit = this.originalCanvas.allStepViews.length;

      this.originalCanvas.allStepViews.forEach(function(step, index) {

        if(index < (limit - 1)) {

          if(! step.circle.curve) {
            step.circle.curve = new path(step.circle);
            this.canvas.add(step.circle.curve);
          } else {
            step.circle.curve.setVisible(true);
            this.canvas.bringToFront(step.circle.curve);
          }
        }
        step.circle.moveCircleWithStep();
        moveRampLineService.manageDrag(step.circle.circleGroup);
        this.canvas.bringToFront(step.circle.circleGroup);

        if(step.model.ramp.collect_data) {
          step.circle.gatherDataDuringRampGroup.setVisible(true);
        }
        this.canvas.bringToFront(step.circle.gatherDataDuringRampGroup);

      }, this);
      this.canvas.renderAll();
    };

    this.findAllCircles = function() {

      var tempCirc = null;
      this.findAllCirclesArray.length = 0;

      this.findAllCirclesArray = this.allStepViews.map(function(step, index) {
        if(tempCirc) {
          step.circle.previous = tempCirc;
          tempCirc.next = step.circle;
        }

        tempCirc = step.circle;
        return step.circle;
      });

      return this.findAllCirclesArray;
    };

    // reDrawCircles method is no more used, because it takes up a lot of resources
    
    /*this.reDrawCircles = function() {
      console.log("redraw circle starts here");
      var tempCirc = null;
      this.drawCirclesArray.length = 0;

      this.drawCirclesArray = this.allStepViews.map(function(step, index) {

        step.circle.removeContents();
        delete step.circle;
        step.addCircle();

        if(tempCirc) {
          step.circle.previous = tempCirc;
          tempCirc.next = step.circle;
        }

        tempCirc = step.circle;
        return step.circle;
      }, this);
      console.log("reDrawCircles ends here");
      return this.drawCirclesArray;
    }; */

    return this;
  }
]);
