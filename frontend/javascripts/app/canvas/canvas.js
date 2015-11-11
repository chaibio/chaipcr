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
  'previouslySelected',
  'constants',

  function(ExperimentLoader, $rootScope, stage, $timeout, events, path, stageEvents, stepEvents,
    moveStepRect, moveStageRect, previouslySelected, constants) {

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
      this.editStageStatus = false;
      this.dotCordiantes = {};

      this.images = [
        "gather-data.png",
        "gather-data-image.png",
        "pause.png",
        "pause-middle.png",
        "close.png"
      ];

      this.imageLocation = "/images/";
      this.imageobjects = {};
      if(this.canvas) this.canvas.clear();
      this.canvas = new fabric.Canvas('canvas', {
        backgroundColor: '#FFB300', selection: false, stateful: true
      });

      new events(this, this.$scope); // Fire the events;
      this.createFooterDotCordinates();
      this.loadImages();
    };

    this.setDefaultWidthHeight = function() {

      this.canvas.setHeight(400);
      //var width = (this.allStepViews.length * 128 > 1024) ? this.allStepViews.length * 128 : 1024;
      // Add these numbers to constants.
      this.canvas.setWidth(
        (this.allStepViews.length * constants.stepWidth) +
        ((this.allStageViews.length) * 8) +
        ((this.allStageViews.length) * 2) +
        33 + 33
      );
      var that = this, showScrollbar;
      // Show Hide scroll bar in the top
      this.$scope.scrollWidth = this.canvas.getWidth();
      this.$scope.showScrollbar = (this.canvas.getWidth() > 1024) ? true : false;
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
    this.createFooterDotCordinates = function() {

      this.dotCordiantes = {
        "topDot0": [1, 1], "bottomDot0": [1, 10], "middleDot0": [6.5, 6],
      };

      for(var i = 1; i < 9; i++) {
        this.dotCordiantes["topDot" + i] = [(11 * i) + 1, 1];
        this.dotCordiantes["middleDot" + i] = [(11 * i) + 6.5, 6];
        this.dotCordiantes["bottomDot" + i] = [(11 * i) + 1, 10];
      }

      delete this.dotCordiantes["middleDot" + (i - 1)];
      return this.cordinates;
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

      //this.indicator = moveStepRect.getMoveStepRect(this);
      //this.stageMoveIndicator = moveStageRect.getMoveStepRect(this);
      //this.canvas.add(this.indicator);
      //this.canvas.add(this.stageMoveIndicator);
    };

    this.addDelImage = function() {

      /*this.delImageObj = $.extend({}, this.imageobjects["close.png"]);
      this.delImageObj.opacity = 0;
      this.delImageObj.originX = "left";
      this.delImageObj.originY = "top";
      this.delImageObj.left = -100;
      this.delImageObj.top = 79;
      this.delImageObj.name = "commonDeleteButton";
      this.delImageObj.me = this;
      this.delImageObj.selectable = true;
      this.delImageObj.hasBorders = false;
      this.delImageObj.hasControls = false;
      this.delImageObj.lockMovementY = true;
      this.delImageObj.lockMovementX = true;

      this.canvas.add(this.delImageObj);*/
    };

    this.editStageMode = function(status) {

      var add = (status) ? 25 : -25;
      //this.delImageObj.setOpacity(0);
      if(status === true) {
        this.editStageStatus = status;
        previouslySelected.circle.parent.manageFooter("black");
        previouslySelected.circle.parent.parentStage.changeFillsAndStrokes("black", 4);
      } else {
        previouslySelected.circle.parent.manageFooter("white");
        previouslySelected.circle.parent.parentStage.changeFillsAndStrokes("white", 2);
        this.editStageStatus = status; // This order editStageStatus is changed is important, because changeFillsAndStrokes()
        //Works only if editStageStatus === true
      }

      this.allStageViews.forEach(function(stage, index) {
        stage.dots.setVisible(status);
        stage.stageNameGroup.left = stage.stageNameGroup.left + add;

        stage.childSteps.forEach(function(step, index) {
          step.closeImage.setVisible(status);
          step.dots.setVisible(status);

          if(step.parentStage.model.auto_delta) {
            if(step.index === 0) {

              step.deltaSymbol.setVisible(!status);
            }
            step.deltaGroup.setVisible(!status);
          }

        });
      }, this);
      this.canvas.renderAll();
    };

    this.addNewStage = function(data, currentStage) {

      // Re factor this part.. // what if stage with no step is returned LATER.
      //move the stages, make space.
      var ordealStatus = currentStage.childSteps[currentStage.childSteps.length - 1].ordealStatus,
      originalWidth = currentStage.myWidth,
      add = (data.stage.steps.length > 0) ? 128 + Math.floor(8 / data.stage.steps.length) : 128;

      data.stage.steps.forEach(function(step) {
        currentStage.myWidth = currentStage.myWidth + add;
        currentStage.moveAllStepsAndStages(false);
      });

      currentStage.myWidth = originalWidth; // This is some trick, But I forgot what it was , check back here.
      // okay we puhed stages in front by inflating the current stage and put the old value back.
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
        this.allStepViews.splice(ordealStatus, 0, step);
        ordealStatus = ordealStatus + 1;
      }, this);

      var circles = this.reDrawCircles();
      this.addRampLinesAndCircles(circles);

      this.$scope.applyValues(stageView.childSteps[0].circle);
      stageView.childSteps[0].circle.manageClick(true);
      this.setDefaultWidthHeight();
    };

    return this;
  }
]);
