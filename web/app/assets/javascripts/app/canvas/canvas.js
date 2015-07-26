ChaiBioTech.app = ChaiBioTech.app || {};

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

      $timeout(function(context) {
        context.canvas.renderAll();
      },0 , true, this);

      return this;
    };

    this.addStages = function() {

      var allStages = this.model.protocol.stages;
      var previousStage = null, noOfStages = allStages.length, stageView;

      for (var stageIndex = 0; stageIndex < noOfStages; stageIndex ++) {

        stageView = new stage(allStages[stageIndex].stage, this.canvas, this.allStepViews, stageIndex, this, this.$scope);
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
      stageView.borderRight();
      //this.canvas.add(stageView.borderRight);
      // We should put an infinity symbol if the last step has infinite hold time.
      stageView.findLastStep();
      console.log("Stages added ... !");
      return this;

    };

    /*******************************************************/
      /* This method does the default selection of the step when
         the graph is loaded. obviously allStepViews[0] is the very first step
         This could be changed later to reflext add/delete change*/
    /*******************************************************/
    this.selectStep = function() {

      if(ChaiBioTech.app.newlyCreatedStep) {
        ChaiBioTech.app.newlyCreatedStep.circle.manageClick(true);
        appRouter.editStageStep.trigger("stepSelected", ChaiBioTech.app.newlyCreatedStep);
        ChaiBioTech.app.newlyCreatedStep = null;
      } else {
        this.allStepViews[0].circle.manageClick(true);
        this.$scope.fabricStep = this.allStepViews[0];
        // here we initite stage/step events service.. So now we can listen for changes from the bottom.
        stageEvents.init(this.$scope, this.canvas, this);
        stepEvents.init(this.$scope, this.canvas, this);
      }
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

        this.allStepViews[count].commonFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["common-step.png"]), this.allStepViews[count]);
        this.canvas.add(this.allStepViews[count].commonFooterImage);

        this.allStepViews[count].darkFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["black-footer.png"]), this.allStepViews[count]);
        this.canvas.add(this.allStepViews[count].darkFooterImage);

        this.allStepViews[count].whiteFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["orange-footer.png"]), this.allStepViews[count]);
        this.allStepViews[count].whiteFooterImage.top = 363;
        this.allStepViews[count].whiteFooterImage.left = this.allStepViews[count].left;
        this.canvas.add(this.allStepViews[count].whiteFooterImage);



      }

      return this;
    };

    this.applyPropertyToImages = function(imgObj, stepObj) {

      imgObj.left = stepObj.left - 1;
      imgObj.top = 383;
      imgObj.selectable = true;
      imgObj.hasControls = false;
      imgObj.lockMovementY = true;
      imgObj.visible = false;

      return imgObj;
    };

    this.addRampLinesAndCircles = function(circles) {

      //this.allCircles = null;
      this.allCircles = circles || this.findAllCircles();
      var limit = this.allCircles.length;
      console.log("boom", limit);
      for(i = 0; i < limit; i++) {
        var thisCircle = this.allCircles[i];

        if(i < (limit - 1)) {
          //if(thisCircle.curve) {
            //this.canvas.remove(thisCircle.curve);
            //thisCircle.realign();
            //this.canvas.bringToFront(thisCircle.previous.curve);
            //delete(thisCircle.curve);
          //}
            thisCircle.moveCircle();
            thisCircle.curve = new path(thisCircle);
            this.canvas.add(thisCircle.curve);
            /*if(thisCircle.previous) {
              this.canvas.remove(thisCircle.previous.curve);
              thisCircle.previous.curve = new path(thisCircle.previous);
              this.canvas.add(thisCircle.previous.curve);
            }*/

          this.canvas.bringToFront(thisCircle.parent.rampSpeedGroup);
          if(thisCircle.previous) {
            this.canvas.bringToFront(thisCircle.previous.parent.rampSpeedGroup);
          }
        }

        thisCircle.getCircle();
      }

      console.log("All circles are added ....!!");
      return this;
    };

    this.findAllCircles = function() {

      var i = 0, limit = this.allStepViews.length, circles = [], tempCirc = null;

      for(i = 0; i < limit; i++) {
        if(tempCirc) {
          this.allStepViews[i].circle.previous = tempCirc;
          tempCirc.next = this.allStepViews[i].circle;
        }
        tempCirc = this.allStepViews[i].circle;
        circles.push(this.allStepViews[i].circle);
      }
      return circles;
    };

    this.reDrawCircles = function() {

      var i = 0, limit = this.allStepViews.length, circles = [], tempCirc = null;

      for(i = 0; i < limit; i++) {
        //if(this.allStepViews[i].circle) {
          this.allStepViews[i].circle.removeContents();
          //this.allStepViews[i].circle.remove();
          delete this.allStepViews[i].circle;
        //}
        this.allStepViews[i].addCircle();
        if(tempCirc) {
          this.allStepViews[i].circle.previous = tempCirc;
          tempCirc.next = this.allStepViews[i].circle;
        }
        tempCirc = this.allStepViews[i].circle;
        circles.push(this.allStepViews[i].circle);
      }
      return circles;

    };

    this.addNewStage = function(data, currentStage) {
      console.log(data);
      
      // Make space.
      // Create stage
      // add step and stage into arrays ..
      // Render it

    };

    return this;
  }
]);
