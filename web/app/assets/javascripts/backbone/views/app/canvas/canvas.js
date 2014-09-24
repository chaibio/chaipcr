ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.mainCanvas = null; // This could be used across application to fire

ChaiBioTech.app.Views.fabricCanvas = function(model, appRouter) {

  this.model = model;
  this.allStepViews = [];
  var that = this;
  ChaiBioTech.app.Views.mainCanvas = this.canvas = new fabric.Canvas('canvas', {
    backgroundColor: '#ffb400',
    selection: false,
    stateful: false
  });
  // Moving event handlers into canvas object
  // For better performance and in accordance with fabric js specific
  // For mouse down
  this.canvas.on("mouse:down", function(evt) {
    if(evt.target) {
      switch(evt.target.name)  {

      case "step":
        var me = evt.target.me;
        me.parentStage.selectStage();
        me.selectStep();
      break;

      case "controlCircleGroup":
        var me = evt.target.me;
        me.manageClick();
      break;
      }
    }
  });
  // For dragging
  this.canvas.on('object:moving', function(evt) {
    if(evt.target) {
      switch(evt.target.name) {
        case "controlCircleGroup":
          var targetCircleGroup = evt.target,
          me = evt.target.me;
          me.manageDrag(targetCircleGroup);
        break;
      }
    }
  });
  // We add this handler so that canvas works when scrolled
  $(".canvas-containing").scroll(function(){
    that.canvas.calcOffset();
  });

  this.setDefaultWidthHeight = function() {
    this.canvas.setHeight(420);
    var width = (this.allStepViews.length * 122 > 1024) ? this.allStepViews.length * 120 : 1024
    this.canvas.setWidth(width + 50);
    this.canvas.renderAll();
  };

  this.canvas.on("modelChanged", function(evt) {
    that.model.getLatestModel(that.canvas);
    that.canvas.clear();
    that.canvas.renderAll();
  });

  this.canvas.on("latestData", function() {
    while(that.allStepViews.length > 0) {
      that.allStepViews.pop();
    }
    ChaiBioTech.app.selectedStage = null;
    ChaiBioTech.app.selectedStep = null;
    ChaiBioTech.app.selectedCircle = null;
    that.addStages();
    that.setDefaultWidthHeight();
    that.addinvisibleFooterToStep();
    that.addTemperatureLines();
  })

  this.addStages = function() {
    var allStages = this.model.get("experiment").protocol.stages;
    var stage = {};
    var previousStage = null;

    for (stageIndex in allStages) {
      stageModel = new ChaiBioTech.Models.Stage({"stage": allStages[stageIndex].stage});
      stageView = new ChaiBioTech.app.Views.fabricStage(stageModel, this.canvas, this.allStepViews, stageIndex);

      if(previousStage){
        previousStage.nextStage = stageView;
        stageView.previousStage = previousStage;
      }

      previousStage = stageView;
      stageView.render();
    }
    // Only for the last stage
    stageView.borderRight();
    this.canvas.add(stageView.borderRight).calcOffset();;
  };

  this.addTemperatureLines = function() {
    this.allCircles = null;
    this.allCircles = this.findAllCircles();
    var i = 0, limit = this.allCircles.length;

    for(i = 0; i < limit; i++) {
      this.allCircles[i].getLines(i);
    }
  }

  this.addinvisibleFooterToStep = function() {
    var count = 0, limit = this.allStepViews.length,
    stepDark = "assets/selected-step-01.png",
    stepWhite = "assets/selected-step-02.png",
    stepCommon = "assets/common-step.png";

    addImage = function(count, that, url, image) {
      fabric.Image.fromURL(url, function(img) {
        img.left = that.allStepViews[count].left - 1;
        img.top = 383;
        img.selectable = false;
        img.visible = false;

        if(image == "darkFooter") {
          that.allStepViews[count].darkFooterImage = img;
          that.canvas.add(that.allStepViews[count].darkFooterImage);
        } else if(image == "whiteFooter") {
          img.top = 363;
          img.left = that.allStepViews[count].left;
          that.allStepViews[count].whiteFooterImage = img;
          that.canvas.add(that.allStepViews[count].whiteFooterImage);
        } else if(image == "commonFooter") {
          that.allStepViews[count].commonFooterImage = img;
          that.canvas.add(that.allStepViews[count].commonFooterImage);
        }

        //that.canvas.add(img);
        count = count + 1;

        if(count < limit) {
          addImage(count, that, url, image);
        }
      });
    }

    addImage(0, this, stepCommon, "commonFooter");
    addImage(0, this, stepDark, "darkFooter");
    addImage(0, this, stepWhite, "whiteFooter");
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
