window.ChaiBioTech.ngApp.factory('canvas', [
  'ExperimentLoader',
  '$rootScope',
  'stage',
  '$timeout',
  'events',
  'path',
  'stageEvents',
  'stepEvents',
  function(ExperimentLoader, $rootScope, stage, $timeout, events, path, stageEvents, stepEvents) {

    this.init = function(model) {

      console.log("controller", model);
      this.model = model.protocol;
      this.$scope = model;
      this.allStepViews = [];
      this.allStageViews = [];
      this.canvas = null;
      this.allCircles = null;
      this.drawCirclesArray = [];
      this.findAllCirclesArray = [];
      this.moveLimit = 0; // We set the limit for the movement of the step image to move steps
      this.images = [
        "common-step.png",
        "black-footer.png",
        "orange-footer.png",
        "gather-data.png",
        "gather-data-image.png"
      ];

      this.imageobjects = {};
      if(this.canvas) this.canvas.clear();
      this.canvas = new fabric.Canvas('canvas', {
        backgroundColor: '#ffb400', selection: false, stateful: true
      });

      new events(this, this.$scope); // Fire the events;
      this.loadImages();
    };

    this.setDefaultWidthHeight = function() {

      this.canvas.setHeight(420);
      var width = (this.allStepViews.length * 122 > 1024) ? this.allStepViews.length * 120 : 1024;
      this.canvas.setWidth(width + 50);

      //$timeout(function(context) {
        //context.canvas.renderAll();
        this.canvas.renderAll();
      //},0 , true, this);

      return this;
    };

    this.addStages = function() {

      var allStages = this.model.protocol.stages;
      var previousStage = null, noOfStages = allStages.length, stageView;

      for (var stageIndex = 0; stageIndex < noOfStages; stageIndex ++) {

        stageView = new stage(allStages[stageIndex].stage, this.canvas, this.allStepViews, stageIndex, this, this.$scope, false);
        // We connect the stages like a linked list so that we can go up and down.
        if(previousStage){
          previousStage.nextStage = stageView;
          stageView.previousStage = previousStage;
        }

        previousStage = stageView;
        stageView.render();
        this.allStageViews.push(stageView);
      }
      // Only for the last stage
      stageView.addBorderRight();
      console.log("Stages added ... !");
      return this;

    };

    /*******************************************************/
      /* This method does the default selection of the step when
         the graph is loaded. obviously allStepViews[0] is the very first step
         This could be changed later to reflext add/delete change*/
    /*******************************************************/
    this.selectStep = function() {

        this.allStepViews[0].circle.manageClick(true);
        this.$scope.fabricStep = this.allStepViews[0];
        // here we initiate stage/step events service.. So now we can listen for changes from the bottom.
        stageEvents.init(this.$scope, this.canvas, this);
        stepEvents.init(this.$scope, this.canvas, this);

    };

    this.loadImages = function() {

      console.log("Loading Images ....... !");
      var noOfImages = this.images.length - 1;
      var that = this;
      loadImageRecursion = function(index) {
        fabric.Image.fromURL("assets/" + that.images[index], function(img) {

          that.imageobjects[that.images[index]] = $.extend(true, {}, img);
          if(index < noOfImages) {
            loadImageRecursion(++index);
          } else {
            console.log("All images loaded .... !");
            that.canvas.fire("imagesLoaded");
          }
        });
      };

      loadImageRecursion(0);
    };

    /*******************************************************/
      /* This method adds those footer images on the step. Its a tricky one beacuse images
         are taking longer time to load. So we load it once and clone it to all the steps.
         It uses recursive function to do the job. See the inner function mainWrapper()
      */
    /*******************************************************/
    this.addinvisibleFooterToStep = function() {

      var count = 0;
      var limit = this.allStepViews.length;

      for(count = 0; count < limit; count ++) {

        var step = this.allStepViews[count];

        step.commonFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["common-step.png"]), step);
        this.canvas.add(step.commonFooterImage);

        step.darkFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["black-footer.png"]), step);
        this.canvas.add(step.darkFooterImage);

        step.whiteFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["orange-footer.png"]), step, 'moveStepImage');
        step.whiteFooterImage.top = 365;
        step.whiteFooterImage.left = step.left;
        this.canvas.add(step.whiteFooterImage);

      }

      return this;
    };

    this.applyPropertyToImages = function(imgObj, stepObj, name) {

      imgObj.left = stepObj.left - 1;
      imgObj.top = 384;
      imgObj.selectable = true;
      imgObj.hasControls = false;
      imgObj.lockMovementY = true;
      imgObj.visible = false;
      imgObj.hasBorders = false;
      imgObj.name = name;
      imgObj.step = stepObj;
      return imgObj;
    };

    this.addRampLinesAndCircles = function(circles) {

      this.allCircles = circles || this.findAllCircles();
      var limit = this.allCircles.length, thisCircle;

      for(i = 0; i < limit; i++) {
        thisCircle = this.allCircles[i];

        if(i < (limit - 1)) {

          thisCircle.moveCircle();
          thisCircle.curve = new path(thisCircle);
          this.canvas.add(thisCircle.curve);

          this.canvas.bringToFront(thisCircle.parent.rampSpeedGroup);
          if(thisCircle.previous) {
            this.canvas.bringToFront(thisCircle.previous.parent.rampSpeedGroup);
          }
        }

        thisCircle.getCircle();
      }
      // We should put an infinity symbol if the last step has infinite hold time.
      thisCircle.doThingsForLast();
      console.log("All circles are added ....!!");
      return this;
    };

    this.findAllCircles = function() {

      var i = 0, limit = this.allStepViews.length, tempCirc = null;
      this.findAllCirclesArray.length = 0;

      for(i = 0; i < limit; i++) {
        if(tempCirc) {
          this.allStepViews[i].circle.previous = tempCirc;
          tempCirc.next = this.allStepViews[i].circle;
        }
        tempCirc = this.allStepViews[i].circle;
        this.findAllCirclesArray.push(this.allStepViews[i].circle);
      }
      return this.findAllCirclesArray;
    };

    this.reDrawCircles = function() {

      var i = 0, limit = this.allStepViews.length, tempCirc = null;
      this.drawCirclesArray.length = 0;

      for(i = 0; i < limit; i++) {

        this.allStepViews[i].circle.removeContents();
        delete this.allStepViews[i].circle;
        this.allStepViews[i].addCircle();

        if(tempCirc) {
          this.allStepViews[i].circle.previous = tempCirc;
          tempCirc.next = this.allStepViews[i].circle;
        }
        tempCirc = this.allStepViews[i].circle;
        this.drawCirclesArray.push(this.allStepViews[i].circle);
      }
      return this.drawCirclesArray;
    };

    this.addMoveStepIndicator = function() {

      var smallCircle = new fabric.Circle({
        radius: 4,
        fill: 'black',
        selectable: false,
        left: 63,
        top: 259,
        //top: -2
      });

      var verticalLine = new fabric.Line([0, 0, 0, 263],{
        left: 66,
        top: -2,
        stroke: 'black',
        strokeWidth: 2
      });

      var rect = new fabric.Rect({
        fill: 'white', width: 120, left: 5, height: 40, selectable: false, name: "step", me: this, top: 263
      });

      this.indicator = new fabric.Group([
        verticalLine,
        rect,
        smallCircle,
      ],
        {
          originX: "left",
          originY: "top",
          width: 122,
          left: 33,
          top: 61,
          selectable: false,
          visible: false
        }
      );

      this.canvas.add(this.indicator);
    };

    this.onTheMove = function(movingObject) {

      // 1)create a point or a small rectangle at the farthest end of each steps
      // 2)hit test agaist it
      // May be group the common footer image with the look in the nicks design.
      // Nicks design image is going to be the background.
      // Change the background in the beginning of the scroll
      var length = this.allStepViews.length;

      for(var run = 0; run < length; run ++) {
        if(movingObject.intersectsWithObject(this.allCircles[run].circleGroup)) {
          console.log(run);
          // Make the Jump;
          // use the previou to store the
          return false;
        }
      }
    };

    this.processMovement = function(step) {

      // Make a clone of the step
      var stepClone = $.extend({}, step);
      // Find the place where you left the moved step
      var moveTarget = Math.floor((stepClone.whiteFooterImage.left + 60) / 120);
      // This is a way to understand moving direction.
      if(stepClone.whiteFooterImage.startPosition < stepClone.whiteFooterImage.endPosition) {
        moveTarget = (moveTarget > 0) ? moveTarget - 1 : 0;
      }
      // If the movement is atlest half of the width of the step, we are going to update
      if(Math.abs(stepClone.whiteFooterImage.startPosition - stepClone.whiteFooterImage.endPosition) > 65) {
        // Delete the step you moved
        step.parentStage.deleteStep({}, step);
        // add clone at the place
        var moveToStage = this.allStepViews[moveTarget].parentStage;
        var data = {
          step: stepClone.model
        };
        moveToStage.addNewStep(data, this.allStepViews[moveTarget]);
      } else { // we dont have to update so we update the move whiteFooterImage to old position.
        stepClone.whiteFooterImage.setLeft(stepClone.left + 1);
      }

    };

    this.addNewStage = function(data, currentStage) {

      //move the stages, make space.
      var noOfsteps = data.stage.steps.length, k = 0,
      ordealStatus = currentStage.childSteps[currentStage.childSteps.length - 1].ordealStatus,
      originalWidth = currentStage.myWidth,
      add = (data.stage.steps.length > 1) ? 121.5 : 122.5;
      
      for(k = 0; k < noOfsteps; k++) {
        currentStage.myWidth = currentStage.myWidth + add;
        currentStage.moveAllStepsAndStages(false);
      }

      currentStage.myWidth = originalWidth;

      // now create a stage;
      var stageIndex = currentStage.index + 1;
      var stageView = new stage(data.stage, this.canvas, this.allStepViews, stageIndex, this, this.$scope, true);

      if(currentStage.nextStage) {
        stageView.nextStage = currentStage.nextStage;
        stageView.nextStage.previousStage = stageView;
      }
      currentStage.nextStage = stageView;
      stageView.previousStage = currentStage;

      stageView.updateStageData(1);
      this.allStageViews.splice(stageIndex, 0, stageView);
      stageView.render();

      // configure steps;
      var length = stageView.childSteps.length, l = 0;

      for(l = 0; l < length; l++) {
        stageView.childSteps[l].ordealStatus = ordealStatus + 1;
        stageView.childSteps[l].render();
        stageView.childSteps[l].addImages();

        this.allStepViews.splice(ordealStatus, 0, stageView.childSteps[l]);
        ordealStatus = ordealStatus + 1;
      }

      stageView.childSteps[stageView.childSteps.length - 1].borderRight.setVisible(false);
      if(stageView.nextStage === null) { // if its the last stage
        stageView.addBorderRight();
        this.canvas.remove(stageView.previousStage.borderRight);
      }

      var circles = this.reDrawCircles();
      this.addRampLinesAndCircles(circles);

      this.$scope.applyValues(stageView.childSteps[0].circle);
      stageView.childSteps[0].circle.manageClick(true);
      this.setDefaultWidthHeight();
    };

    return this;
  }
]);
