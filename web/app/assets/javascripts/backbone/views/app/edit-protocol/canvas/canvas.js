ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};
//ChaiBioTech.app.Views.mainCanvas could be used to fire event on html views aoutside of graph
ChaiBioTech.app.Views.mainCanvas = null;

ChaiBioTech.app.Views.fabricCanvas = function(model, appRouter) {

  this.model = model;
  this.allStepViews = new Array();
  this.allStageViews = new Array();
  this.canvas = null;
  this.allCircles = null;
  this.images = [
    "common-step.png",
    "black-footer.png",
    "orange-footer.png",
    "gather-data.png"
  ];

  this.imageobjects = {};

  this.canvas = ChaiBioTech.app.Views.mainCanvas = new fabric.Canvas('canvas', {
    backgroundColor: '#ffb400',
    selection: false,
    stateful: true
  });

  var that = this;

  /*******************************************************/
    /* Initial adjustment of the canvas width. We take account of,
       the number of steps we have and multiply with 120. 120 is
       normal width of a step */
  /*******************************************************/

  this.setDefaultWidthHeight = function() {

    this.canvas.setHeight(420);
    var width = (this.allStepViews.length * 122 > 1024) ? this.allStepViews.length * 120 : 1024
    this.canvas.setWidth(width + 50);
    this.canvas.renderAll();
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
      appRouter.editStageStep.trigger("stepSelected", this.allStepViews[0]);
    }
  };

  /*******************************************************/
    /* This method adds all the stages to the graph.
       And Each stage in turn adds its own steps. Note that we create
       a stage model which is a backbone model and fuse it together to fabric. */
  /*******************************************************/
  this.addStages = function() {

    var allStages = this.model.get("experiment").protocol.stages;
    var stage = {};
    var previousStage = null;

    for (stageIndex in allStages) {
      stageModel = new ChaiBioTech.Models.Stage({"stage": allStages[stageIndex].stage});
      stageView = new ChaiBioTech.app.Views.fabricStage(stageModel, this.canvas, this.allStepViews, stageIndex, this);
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
    this.canvas.add(stageView.borderRight);
    // We should put an infinity symbol if the last step has infinite hold time.
    stageView.findLastStep();
    console.log("Stages added ... !")
    return this;
  };

  /*******************************************************/
    /* This method adds ramp lines and circles. look at findAllCircles() method */
  /*******************************************************/
  this.addRampLinesAndCircles = function() {

    this.allCircles = null;
    this.allCircles = this.findAllCircles();
    var limit = this.allCircles.length;

    for(i = 0; i < limit; i++) {
      var thisCircle = this.allCircles[i];

      if(i < (limit - 1)) {
        thisCircle.curve = new ChaiBioTech.app.Views.fabricPath(thisCircle);
        this.canvas.add(thisCircle.curve);
        //this.canvas.bringToFront(thisCircle.parent.rampSpeedGroup);
        if(thisCircle.previous) {
          this.canvas.bringToFront(thisCircle.previous.parent.rampSpeedGroup);
        }
      }

      thisCircle.getCircle();
    }

    console.log("All circles are drawn ....!!");
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
          console.log("All images loaded .... !", that.imageobjects);
          that.canvas.fire("imagesLoaded");
        }
      });
    }

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

    for(var count = 0; count < limit; count ++) {

      this.allStepViews[count].commonFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["common-step.png"]), this.allStepViews[count]);
      this.canvas.add(this.allStepViews[count].commonFooterImage);

      this.allStepViews[count].darkFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["black-footer.png"]), this.allStepViews[count]);
      this.canvas.add(this.allStepViews[count].darkFooterImage);

      this.allStepViews[count].whiteFooterImage = this.applyPropertyToImages($.extend({}, this.imageobjects["orange-footer.png"]), this.allStepViews[count]);
      this.allStepViews[count].whiteFooterImage.top = 363;
      this.allStepViews[count].whiteFooterImage.left = this.allStepViews[count].left;
      this.canvas.add(this.allStepViews[count].whiteFooterImage);

      this.allStepViews[count].circle.gatherDataImage = $.extend({}, this.imageobjects["gather-data.png"]);
      this.allStepViews[count].circle.gatherDataImage.originX = "center";
      this.allStepViews[count].circle.gatherDataImage.originY = "center";

      this.allStepViews[count].circle.gatherDataImageOnMoving = $.extend({}, this.imageobjects["gather-data.png"]);
      this.allStepViews[count].circle.gatherDataImageOnMoving.originX = "center";
      this.allStepViews[count].circle.gatherDataImageOnMoving.originY = "center";

      this.allStepViews[count].circle.gatherDataImageMiddle = $.extend({}, this.imageobjects["gather-data.png"]);
      this.allStepViews[count].circle.gatherDataImageMiddle.originX = "center";
      this.allStepViews[count].circle.gatherDataImageMiddle.originY = "center";
      this.allStepViews[count].circle.gatherDataImageMiddle.setVisible(false);

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
  },

  /*******************************************************/
    /* This method collects all the circles in each and every step,
       and tie those circles together. Now we have a linked list of circles.
       We do it so that we can connect these circles with ramp lines.
    */
  /*******************************************************/
  this.findAllCircles = function() {

    var i = 0;
    var limit = this.allStepViews.length;
    var circles = [];
    var tempCirc = null;

    for(i = 0; i < limit; i++) {
      if(tempCirc) {
        this.allStepViews[i].circle["previous"] = tempCirc;
        tempCirc.next = this.allStepViews[i].circle;
      }
      tempCirc = this.allStepViews[i].circle;
      circles.push(this.allStepViews[i].circle);
    }
    return circles;
  };

  /*******************************************************/
    // We fire up all the events initializing fabricEvents
  /*******************************************************/
  this.fireUpEvents = new ChaiBioTech.app.Views.fabricEvents(this, appRouter);

  return this;
}
