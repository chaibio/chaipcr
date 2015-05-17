ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};
//ChaiBioTech.app.Views.mainCanvas could be used to fire event on html views aoutside of graph
ChaiBioTech.app.Views.mainCanvas = null;

ChaiBioTech.app.Views.fabricCanvas = function(model, appRouter) {

  this.model = model;
  this.allStepViews = new Array();
  this.allStageViews = new Array();
  this.canvas = null;
  this.allCircles = null;

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
    return this;
  };

  this.addMoveImageForStages = function() {

    var noOfStages = this.allStageViews.length;

    for(var i = 0; i < noOfStages; i++) {
      var currentStage = this.allStageViews[i];
      //console.log(currentStage);
      var moveImg = $.extend({}, that.moveImage);
      moveImg.left = currentStage.left + (currentStage.myWidth - 20);
      moveImg.top = 18;
      moveImg.setVisible(false);
      moveImg.lockMovementY = true;
      moveImg.hasControls = false;
      moveImg.hasBorders = false;
      moveImg.stage = currentStage;
      currentStage.moveImg = moveImg;
      this.canvas.add(moveImg);
    }

  }
  /*******************************************************/
    /* This method adds ramp lines and circles. look at findAllCircles() method */
  /*******************************************************/
  this.addRampLinesAndCircles = function() {
    this.allCircles = null;
    this.allCircles = this.findAllCircles();
    var i = 0, limit = this.allCircles.length;

    for(i = 0; i < limit; i++) {
      this.allCircles[i].getLinesAndCircles();
    }
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
    var imageSourceArray = [ // common, dark, white
      "assets/common-step.png",
      "assets/selected-step-01.png",
      "assets/selected-step-02.png"
     ];
    var that = this;

    mainWrapper = function(index, callback) {

      fabric.Image.fromURL(imageSourceArray[index], function(img) {
        for(var count = 0; count < limit; count ++) {

          var imaging = $.extend({}, img);
          imaging.left = that.allStepViews[count].left - 1;
          imaging.top = 383;
          imaging.selectable = imaging.visible = false;

          if(index === 0) {
            that.allStepViews[count].commonFooterImage = imaging;
            that.canvas.add(that.allStepViews[count].commonFooterImage);
          } else if(index === 1) {
            that.allStepViews[count].darkFooterImage = imaging;
            that.canvas.add(that.allStepViews[count].darkFooterImage);
          } else if(index === 2) {
            imaging.top = 363;
            imaging.left = that.allStepViews[count].left;
            that.allStepViews[count].whiteFooterImage = imaging;
            that.canvas.add(that.allStepViews[count].whiteFooterImage);
          }
        }

        if(++ index < 3) {
          mainWrapper(index);
        } else {
          // Calls the moveImage function which loads moveImage for stages and steps.
          that.addMoveImage();
        }
      });
    }
    // This calls to add images of gather data.
    this.addGatherDataImage(this, "assets/gather-data.png", 0, limit)
    mainWrapper(0);

  };

  this.addMoveImage = function() {

    var src = "assets/move.png";
    var that = this;

    fabric.Image.fromURL(src, function(img) {
      that.moveImage = img;
      // As we have loaded all the Images Now we fire "imagesLoaded";
      that.canvas.fire("imagesLoaded");
    });
  };

  /*******************************************************/
    /* This method adds all the Gather Data Images. Here too we
      clone the image in the image load function callback.
    */
  /*******************************************************/
  this.addGatherDataImage = function(that, url, count, limit) {

      fabric.Image.fromURL(url, function(img) {
        img.originX = "center";
        img.originY = "center";
        cloneImgObject = function(that, url, count) {
          that.allStepViews[count].circle.gatherDataImage = $.extend({},img);
          that.allStepViews[count].circle.gatherDataImageMiddle = $.extend({},img);
          that.allStepViews[count].circle.gatherDataImageMiddle.setVisible(false);

          if(++ count < limit) {
            cloneImgObject(that, url, count);
          }
        }
        cloneImgObject(that, url, 0);
      });

  };

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
