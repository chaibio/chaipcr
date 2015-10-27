window.ChaiBioTech.ngApp.factory('canvas', [
  'ExperimentLoader',
  '$rootScope',
  'stage',
  '$timeout',
  'events',
  'path',
  'stageEvents',
  'stepEvents',
  'moveStepRect',
  'moveStageRect',
  function(ExperimentLoader, $rootScope, stage, $timeout, events, path, stageEvents, stepEvents, moveStepRect, moveStageRect) {

    this.init = function(model) {

      console.log("controller", model, "hi hi Jossie");
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
        "gather-data-image.png",
        "drag-footer-image.png",
        "pause.png",
        "pause-middle.png"
      ];

      this.imageLocation = "/images/";
      this.imageobjects = {};
      if(this.canvas) this.canvas.clear();
      this.canvas = new fabric.Canvas('canvas', {
        backgroundColor: '#FFB300', selection: false, stateful: true
      });

      new events(this, this.$scope); // Fire the events;
      this.loadImages();
    };

    this.setDefaultWidthHeight = function() {

      this.canvas.setHeight(400);
      var width = (this.allStepViews.length * 128 > 1024) ? this.allStepViews.length * 128 : 1024;
      this.canvas.setWidth(width + 120);

      //$timeout(function(context) {
        //context.canvas.renderAll();
        this.canvas.renderAll();
      //},0 , true, this);

      return this;
    };

    this.addStages = function() {

      var allStages = this.model.protocol.stages;
      var previousStage = null, noOfStages = allStages.length, stageView;

      this.allStageViews = allStages.map(function(stageData, index) {

        stageView = new stage(stageData.stage, this.canvas, this.allStepViews, index, this, this.$scope, false);
        // We connect the stages like a linked list so that we can go up and down.
        if(previousStage){
          previousStage.nextStage = stageView;
          stageView.previousStage = previousStage;
        }

        previousStage = stageView;
        stageView.render();
        return stageView;
      }, this);

      //stageView.addBorderRight();
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

      var noOfImages = this.images.length - 1;
      var that = this;
      loadImageRecursion = function(index) {
        fabric.Image.fromURL(that.imageLocation + that.images[index], function(img) {

          that.imageobjects[that.images[index]] = img;
          if(index < noOfImages) {
            loadImageRecursion(++index);
          } else {
            console.log(noOfImages + " images loaded .... !");
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

      this.allStepViews.forEach(function(step) {
        this.addImagesC(step);
      }, this);

      return this;
    };

    this.addImagesC = function(step) {

      step.commonFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["common-step.png"]), step, 'commonStep');
      //this.canvas.add(step.commonFooterImage);

      step.darkFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["black-footer.png"]), step, 'blackFooter');
      //this.canvas.add(step.darkFooterImage);

      step.whiteFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["orange-footer.png"]), step, 'moveStepImage');
      step.whiteFooterImage.top = 365;
      step.whiteFooterImage.left = step.left;
      //this.canvas.add(step.whiteFooterImage);

    };

    this.applyPropertyToImages = function(imgObj, stepObj, name) {

      imgObj.left = stepObj.left - 1;
      imgObj.top = 384;
      imgObj.selectable = false;
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

    this.findAllCircles = function() {

      var tempCirc = null;
      this.findAllCirclesArray.length = 0;

      this.findAllCirclesArray = this.allStepViews.map(function(step) {

        if(tempCirc) {
          step.circle.previous = tempCirc;
          tempCirc.next = step.circle;
        }
        tempCirc = step.circle;
        return step.circle;
      });

      return this.findAllCirclesArray;
    };

    this.reDrawCircles = function() {

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

      return this.drawCirclesArray;
    };

    this.addMoveStepIndicator = function() {

      this.indicator = moveStepRect.getMoveStepRect(this);
      this.stageMoveIndicator = moveStageRect.getMoveStepRect(this);
      //this.canvas.add(this.indicator);
      //this.canvas.add(this.stageMoveIndicator);
    };

    this.addNewStage = function(data, currentStage) {

      // Re factor this part..
      //move the stages, make space.
      var ordealStatus = currentStage.childSteps[currentStage.childSteps.length - 1].ordealStatus,
      originalWidth = currentStage.myWidth,
      add = (data.stage.steps.length > 1) ? 121.5 : 122.5;

      data.stage.steps.forEach(function(step) {
        currentStage.myWidth = currentStage.myWidth + add;
        currentStage.moveAllStepsAndStages(false);
      });

      currentStage.myWidth = originalWidth; // This is some trick, But I forgot what it was , check back here.

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
      stageView.childSteps.forEach(function(step) {

        step.ordealStatus = ordealStatus + 1;
        step.render();
        step.addImages();

        this.allStepViews.splice(ordealStatus, 0, step);
        ordealStatus = ordealStatus + 1;
      }, this);

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
