ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};
  /**************************************
    These are the main fabric events happening
    Remeber all the events are happening on the canvas, so we can't write
    handler for individual object. So the approch is different from DOM
    all the events are send from canvas and we check if the event has particular target.
  ***************************************/

ChaiBioTech.app.Views.fabricEvents = function(C, appRouter) {
  // C is canvas object and C.canvas is the fabric canvas object
  this.canvas = C.canvas;

  /**************************************
      what happens when click is happening in canvas.
      what we do is check if the click is up on some particular events.
      and we send the changes to backbone views.
  ***************************************/
  this.canvas.on("mouse:down", function(evt) {
    if(evt.target) {
      switch(evt.target.name)  {

      case "step":
        var me = evt.target.me;
        me.circle.manageClick();
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

  /**************************************
      Here we write what happens when we drag over the canvas.
      here too we look for the target in the event and do the action.
  ***************************************/
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

  /**************************************
      When the dragging of the object is finished
  ***************************************/
  this.canvas.on('object:modified', function(evt) {
    if(evt.target) {
      if(evt.target.name === "controlCircleGroup") {
        // Right now we have only one item here otherwise switch case
        var me = evt.target.me;
        var targetCircleGroup = evt.target;
        appRouter.editStageStep.trigger("stepDrag", me);
        var temp = evt.target.me.temperature.text;
        me.model.changeTemperature(parseFloat(temp.substr(0, temp.length - 1)));
      }
    }
  });

  /**************************************
      A tricky one, fired from the DOM perspective. When we have long
      canvas and when we scroll canvas recalculate the offset.
  ***************************************/
  $(".canvas-containing").scroll(function(){
    C.canvas.calcOffset();
  });

  /**************************************
       When all the images are loaded up
       We fire this event
       Note that it takes some more time to load images, better avaoid images
       or wait for images to complete
  ***************************************/
  this.canvas.on("imagesLoaded", function() {
    C.addRampLinesAndCircles();
    C.selectStep();
    C.canvas.renderAll();
  });

 /**************************************
      Changed from bottom means , those values were changed from bottom
      of the screen where we can type in those values. This is how we
      bridge backbone views and fabric canvas.
 ***************************************/
 this.canvas.on("temperatureChangedFromBottom", function(changedStep) {
    changedStep.circle.getTop();
    changedStep.circle.circleGroup.top = changedStep.circle.top;
    changedStep.circle.manageDrag(changedStep.circle.circleGroup);
    changedStep.circle.circleGroup.setCoords();
    C.canvas.renderAll();
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

  this.canvas.on("holdTimeChangedFromBottom", function(changedStep) {
    changedStep.circle.changeHoldTime();
    //Check the last step. See if the last step has zero and put infinity in that case.
    C.allStepViews[C.allStepViews.length - 1].circle.doThingsForLast();
  });

  /**************************************
       When a model in the server changed
       changes like add step/stage or delete step/stage.
  ***************************************/
  this.canvas.on("modelChanged", function(evtData) {

    var keyVal = Object.keys(evtData)[0];

    if(keyVal == "step") {
      ChaiBioTech.app.newStepId = evtData[keyVal].id;
    } else if(keyVal == "stage") {
      ChaiBioTech.app.newStepId = evtData[keyVal].steps[0].step.id;
    } else {
      // Incase we delete a step..!!
      if(ChaiBioTech.app.selectedStep.previousStep) {
        var prevStep = ChaiBioTech.app.selectedStep.previousStep;
        ChaiBioTech.app.newStepId = prevStep.model.get("step").id;
      } else if(ChaiBioTech.app.selectedStep.nextStep) {
        var nxtStep = ChaiBioTech.app.selectedStep.nextStep;
        ChaiBioTech.app.newStepId = nxtStep.model.get("step").id;
      }
    }

    C.model.getLatestModel(C.canvas);
    C.canvas.clear();
  });

  /**************************************
       When changed data after add/delete step/stage, we first remove all
       the data saved.
  ***************************************/
  this.canvas.on("latestData", function() {
    // re instantiate allStepViews. So that we can add fresh data.
    C.allStepViews = new Array();

    ChaiBioTech.app.selectedStage = null;
    ChaiBioTech.app.selectedStep = null;
    ChaiBioTech.app.selectedCircle = null;
    // Then we chain the actions so that it adds all the UI stuffs
    C.addStages().setDefaultWidthHeight().addinvisibleFooterToStep();
  });
};
