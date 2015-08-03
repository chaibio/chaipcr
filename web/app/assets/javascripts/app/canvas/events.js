  /**************************************
    These are the main fabric events happening
    Remeber all the events are happening on the canvas, so we can't write
    handler for individual object. So the approch is different from DOM
    all the events are send from canvas and we check if the event has particular target.
  ***************************************/
window.ChaiBioTech.ngApp.factory('events', [
  'ExperimentLoader',
  function(ExperimentLoader) {
    return function(C, $scope) {

      this.canvas = C.canvas;
      console.log("loaded .... !", ExperimentLoader);
      /**************************************
          what happens when click is happening in canvas.
          what we do is check if the click is up on some particular events.
          and we send the changes to backbone views.
      ***************************************/
      this.canvas.on("mouse:down", function(evt) {
        if(evt.target) {
          var me;
          switch(evt.target.name)  {

          case "stepGroup":
            me = evt.target.me;
            me.circle.manageClick();
            console.log(me.circle.parent.uniqueName);
            $scope.applyValuesFromOutSide(me.circle);
          break;

          case "controlCircleGroup":
            me = evt.target.me;
            me.manageClick();
            $scope.applyValuesFromOutSide(me);
          break;

          case "moveStepImage":
            var moveStep = evt.target.moveStep;
            moveStep.stepRect.setFill("yellow");
            C.canvas.setActiveGroup(moveStep.stepGroup);
          break;

          }
        }
      });

      this.canvas.on("mouse:up", function(evt) {
        if(evt.target) {
          switch(evt.target.name)  {

          case "moveStepImage":
              var moveStep = evt.target.moveStep;
              //C.canvas.bringToFront(moveStep.stepGroup);
              //moveStep.stepRect.setFill("red");
              //C.canvas.setActiveGroup(moveStep.stepGroup);
              //C.canvas.renderAll();
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
              $scope.$apply(function() {
                $scope.step.temperature = me.model.temperature;
              });
            break;

            case "moveStepImage":
              var moveStep = evt.target.moveStep;
              //moveStep.stepGroup.setLeft(evt.target.left);
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
            //appRouter.editStageStep.trigger("stepDrag", me);
            var temp = evt.target.me.temperature.text;
            ExperimentLoader.changeTemperature($scope)
              .then(function(data) {
                console.log(data);
              });
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
        C.addStages().setDefaultWidthHeight().addinvisibleFooterToStep().addRampLinesAndCircles();
        C.selectStep();
        C.canvas.renderAll();
      });

      /**************************************
           When a model in the server changed
           changes like add step/stage or delete step/stage.
      ***************************************/
      this.canvas.on("modelChanged", function(evtData) {
        console.log(evtData);
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
        C.allStepViews = [];

        ChaiBioTech.app.selectedStage = null;
        ChaiBioTech.app.selectedStep = null;
        ChaiBioTech.app.selectedCircle = null;
        // Then we chain the actions so that it adds all the UI stuffs
        C.addStages().setDefaultWidthHeight().addinvisibleFooterToStep().addRampLinesAndCircles();
        C.selectStep();
        C.canvas.renderAll();
      });
    };
  }
]);
