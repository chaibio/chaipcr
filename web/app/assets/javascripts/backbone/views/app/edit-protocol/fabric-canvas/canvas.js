ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.mainCanvas = null; // This could be used across application to fire

ChaiBioTech.app.Views.fabricCanvas = function(model, appRouter) {

  this.model = model;
  this.allStepViews = [];
  var that = this;

  ChaiBioTech.app.Views.mainCanvas = this.canvas = new fabric.Canvas('canvas', {
    backgroundColor: '#ffb400',
    selection: false,
    stateful: true
  });

  this.fireUpEvents = new ChaiBioTech.app.Views.fabricEvents(this);

  this.setDefaultWidthHeight = function() {
    this.canvas.setHeight(420);
    var width = (this.allStepViews.length * 122 > 1024) ? this.allStepViews.length * 120 : 1024
    this.canvas.setWidth(width + 50);
    this.canvas.renderAll();
    return this;
  };


  this.selectStep = function() {
    this.allStepViews[0].circle.manageClick(true);
    this.canvas.renderAll();
    appRouter.editStageStep.trigger("stepSelected", this.allStepViews[0]);
  }

  this.addStages = function() {
    var allStages = this.model.get("experiment").protocol.stages;
    var stage = {};
    var previousStage = null;

    for (stageIndex in allStages) {
      stageModel = new ChaiBioTech.Models.Stage({"stage": allStages[stageIndex].stage});
      stageView = new ChaiBioTech.app.Views.fabricStage(stageModel, this.canvas, this.allStepViews, stageIndex, this);

      if(previousStage){
        previousStage.nextStage = stageView;
        stageView.previousStage = previousStage;
      }

      previousStage = stageView;
      stageView.render();
    }
    // Only for the last stage
    stageView.borderRight();
    this.canvas.add(stageView.borderRight);
    stageView.findLastStep();
    return this;
  };

  this.addRampLinesAndCircles = function() {
    this.allCircles = null;
    this.allCircles = this.findAllCircles();
    var i = 0, limit = this.allCircles.length;

    for(i = 0; i < limit; i++) {
      this.allCircles[i].getLinesAndCircles();
    }
  }

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

        index = index + 1;
        if(index < 3) {
          mainWrapper(index);
        } else {
          that.canvas.fire("imagesLoaded");
        }
      });
    }

    this.addGatheDataImage(this, "assets/gather-data.png", 0, limit)
    mainWrapper(0);

  }

  this.addGatheDataImage = function(that, url, count, limit) {

      fabric.Image.fromURL(url, function(img) {
        img.originX = "center";
        img.originY = "center";
        cloneImgObject = function(that, url, count) {
          that.allStepViews[count].circle.gatherDataImage = $.extend({},img);
          that.allStepViews[count].circle.gatherDataImageMiddle = $.extend({},img);
          that.allStepViews[count].circle.gatherDataImageMiddle.setVisible(false);
          count = count + 1;
          if(count < limit) {
            cloneImgObject(that, url, count);
          }
        }
        cloneImgObject(that, url, 0);
      });

  }

  this.findAllCircles = function() {
    var i = 0, limit = this.allStepViews.length, circles = [], tempCirc = null;
    for(i = 0; i < limit; i++) {
      if(tempCirc) {
        // U could do the switch with array itself,
        // but definitely it doesn't look good.
        this.allStepViews[i].circle["previous"] = tempCirc;
        tempCirc.next = this.allStepViews[i].circle;
      }
      tempCirc = this.allStepViews[i].circle;
      circles.push(this.allStepViews[i].circle);
    }
    return circles;
  }
  return this;
}
