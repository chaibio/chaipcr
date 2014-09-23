ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};

ChaiBioTech.app.Views.mainCanvas = null; // This could be used across application to fire
// Events mon canvas

ChaiBioTech.app.Views.fabricCanvas = function(model, appRouter) {

  // Re write this part like other files
  this.model = model;
  this.allStepViews = [];
  var that = this;
  ChaiBioTech.app.Views.mainCanvas = this.canvas = new fabric.Canvas('canvas', {
    backgroundColor: '#ffb400',
    selection: false,
    stateful: false
    //selectionColor: 'green'
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
    //that.canvas.clear();
    //that.canvas.renderAll();
  });

  this.canvas.on("latestData", function() {
    console.log("Latest data", that.model);
    //that.allStepViews = [];
    while(that.allStepViews.length > 0) {
      that.allStepViews.pop();
    }
    ChaiBioTech.app.selectedStage = null;
    ChaiBioTech.app.selectedStep = null;
    that.addStages();
    that.addinvisibleFooterToStep();
    that.setDefaultWidthHeight();
    that.addTemperatureLines();
    that.setDefaultWidthHeight();
    that.canvas.calcOffset();

  })

  this.addStages = function() {
    var allStages = this.model.get("experiment").protocol.stages;
    console.log(allStages);
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

    //this.canvas.calcOffset();

    // This is a bad way to trigger a click in the canvas so that Ostrich Sans is
    // placed correctly. Interestingly if open sans is used , it works fine.
    /*var options = {};
    options.e = {};
    options.e.clientX = 0;
    options.e.clientY = 0;
    //this.canvas.trigger('mouse:down', options);
    //this.canvas.trigger('mouse:up', options); */
  };

  this.addTemperatureLines = function() {
    this.allCircles = null;
    this.allCircles = this.findAllCircles();
    console.log(this.allCircles);
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
        //console.log("Inside", image);
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
