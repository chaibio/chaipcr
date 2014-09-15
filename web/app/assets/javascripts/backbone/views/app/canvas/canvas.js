ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricCanvas = function(model) {

  // Re write this part like other files
  this.model = model;
  this.allStepViews = [];
  this.canvas = new fabric.Canvas('canvas', {
    backgroundColor: '#ffb400',
    selectionColor: 'green'
  });

  this.canvas.on("mouse:down", function(options) {
    console.log(options.e.clientX, options.e.clientY);
  });

  this.setDefaultWidthHeight = function() {
    this.canvas.setHeight(420);
    this.canvas.setWidth(1024);
    this.canvas.renderAll();
  };

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
    this.canvas.add(stageView.borderRight);

    // This is a bad way to trigger a click in the canvas so that Ostrich Sans is
    // placed correctly. Interestingly if open sans is used , it works fine.
    var options = {};
    options.e = {};
    options.e.clientX = 0;
    options.e.clientY = 0;
    this.canvas.trigger('mouse:down', options);
    this.canvas.trigger('mouse:up', options);
  };

  this.addTemperatureLines = function() {
    this.allCircles = this.findAllCircles();
    var i = 0, limit = this.allCircles.length;

    for(i = 0; i < limit; i++) {
      this.allCircles[i].getLines(i);
    }

    //console.log("wooooo", this.AllCircles);

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
  // May be move the placing image into this place .. Simply using all the available steps.
  // May be a recursive function will do it.
  return this;
}
