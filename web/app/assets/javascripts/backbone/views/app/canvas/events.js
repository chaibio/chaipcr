ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};
// Moving event handlers into canvas object
// For better performance and in accordance with fabric js specific
// For mouse down
ChaiBioTech.app.Views.fabricEvents = function(C) {
  this.canvas = C.canvas;

  this.canvas.on("mouse:down", function(evt) {
    if(evt.target) {
      switch(evt.target.name)  {

      case "step":
        var me = evt.target.me;
        me.circle.manageClick();
        //me.parentStage.selectStage();
        //me.selectStep();
        // Sending data to backbone
        appRouter.editStageStep.trigger("stepSelected", me);
      break;

      case "controlCircleGroup":
        var me = evt.target.me;
        me.manageClick();
        appRouter.editStageStep.trigger("stepSelected", me.parent);
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
          appRouter.editStageStep.trigger("stepDrag", me);
        break;
      }
    }
  });
  // when scrolling is finished
  this.canvas.on('object:modified', function(evt) {
    if(evt.target) {
      if(evt.target.name === "controlCircleGroup") {// Right now we have only one item here otherwise switch case
        var me = evt.target.me;
        var targetCircleGroup = evt.target;
        var temp;
        appRouter.editStageStep.trigger("stepDrag", me);
        temp = evt.target.me.temperature.text;
        me.model.changeTemperature(parseFloat(temp.substr(0, temp.length - 1)));
      }
    }
  });
  // We add this handler so that canvas works when scrolled
  $(".canvas-containing").scroll(function(){
    C.canvas.calcOffset();
  });

  this.canvas.on("imagesLoaded", function() {
    C.addRampLinesAndCircles();
    C.selectStep();
    C.canvas.renderAll();
  });

 this.canvas.on("temperatureChangedFromBottom", function(changedStep) {
    //Here is the change from bottom edit part with temperature change
    changedStep.circle.getTop();
    changedStep.circle.circleGroup.top = changedStep.circle.top;
    changedStep.circle.manageDrag(changedStep.circle.circleGroup);
    changedStep.circle.circleGroup.setCoords();
  });

  this.canvas.on("rampSpeedChangedFromBottom", function(changedStep) {
    changedStep.showHideRamp();
  });

  this.canvas.on("stepNameChangedFromBottom", function(changedStep) {
    changedStep.updateStepName();
  });

  this.canvas.on("cycleChangedFromBottom", function(changedStep) {
    changedStep.parentStage.changeCycle();
  });
}
