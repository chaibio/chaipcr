  /**************************************
    These are the main fabric events happening
    Remeber all the events are happening on the canvas, so we can't write
    handler for individual object. So the approch is different from DOM
    all the events are send from canvas and we check if the event has particular target.
  ***************************************/
window.ChaiBioTech.ngApp.factory('events', [
  'ExperimentLoader',
  'previouslySelected',
  'popupStatus',

  function(ExperimentLoader, previouslySelected, popupStatus) {
    return function(C, $scope) {

      this.canvas = C.canvas;
      var that = this;
      console.log("Events loaded .... !", ExperimentLoader);
      // We write this handler so that gather data popup is forced to hide when
      // clicked at some other part of the page, Given pop up is active.

      angular.element('body').click(function(evt) {
        if(popupStatus.popupStatusGatherData && evt.target.parentNode.id != "gather-data-button") {
            // Here we induce a click so that, angular hides the popup.
            angular.element('#gather-data-button').click();
        } else if(popupStatus.popupStatusAddStage && evt.target.id != "add-stage") {
            angular.element('#add-stage').click();
        }

      });

      this.selectStep = function(circle) {

        $scope.curtain.hide();
        circle.manageClick();
        $scope.applyValuesFromOutSide(circle);
      };

      this.canvas.on("mouse:over", function(evt) {
        if(evt.target) {
          var me;
          switch(evt.target.name) {

            case "moveStepImage":

              evt.target.setVisible(false);
              me = evt.target.step;
              C.indicator.changeText(me.parentStage.index, me.index);
              C.indicator.currentStep = me;
              C.moveLimit = C.allStepViews[C.allStepViews.length - 1].left + 3;
              C.canvas.bringToFront(C.indicator);
              C.indicator.setLeft(evt.target.left + 4);
              C.indicator.setCoords();
              C.indicator.setVisible(true);
              C.canvas.renderAll();
          }
        }
      });

      this.canvas.on("mouse:out", function(evt) {
        if(evt.target) {
          var me;
          switch(evt.target.name) {

            case "dragFooter":

              evt.target.setVisible(false);
              me = evt.target.step;
              me.whiteFooterImage.setVisible(true);
              C.indicator.setVisible(false);
              C.canvas.renderAll();
              break;

            case "dragStepGroup":

              evt.target.setVisible(false);
              me = evt.target.currentStep;
              me.whiteFooterImage.setVisible(true);
              C.canvas.renderAll();
              break;

          }
        }
      });
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
              that.selectStep(me.circle);

            break;

            case "controlCircleGroup":

              me = evt.target.me;
              that.selectStep(me);

            break;

            case "orangeFooter":

              me = evt.target.step;
              that.selectStep(me.circle);

            break;

            case "dragStepGroup":

              evt.target.startPosition = evt.target.left;
              C.moveLimit = C.allStepViews[C.allStepViews.length - 1].left + 3;
              C.canvas.bringToFront(C.indicator);
              C.canvas.renderAll();

            break;

          }
        } else { // if the click is on canvas

          $scope.curtain.show();
          var circle = previouslySelected.circle;
          circle.parent.parentStage.unSelectStage();
          circle.parent.unSelectStep();
          circle.makeItSmall();
        }
      });

      this.canvas.on("mouse:up", function(evt) {
        if(evt.target) {
          switch(evt.target.name)  {

            case "dragFooter":
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

            case "dragStepGroup":

              var indicator = evt.target;
              if(indicator.left < 35) {
                indicator.setLeft(35);
              } else if(indicator.left > C.moveLimit) {
                indicator.setLeft(C.moveLimit);
              } else {
                indicator.setLeft(evt.target.left);
                indicator.setCoords();
                indicator.onTheMove(C);
              }

            break;
          }
        }
      });

      /**************************************
          When the dragging of the object is finished
      ***************************************/
      this.canvas.on('object:modified', function(evt) {

        if(evt.target) {

          switch(evt.target.name) {

            case "controlCircleGroup":
              // Right now we have only one item here otherwise switch case
              var me = evt.target.me;
              var targetCircleGroup = evt.target;
              //appRouter.editStageStep.trigger("stepDrag", me);
              var temp = evt.target.me.temperature.text;
              ExperimentLoader.changeTemperature($scope)
                .then(function(data) {
                  console.log(data);
              });
            break;

            case "dragStepGroup":

              var indicate = evt.target;
              var step = indicate.currentStep;
              indicate.setVisible(false);
              step.commonFooterImage.setVisible(true);
              indicate.endPosition = indicate.left;
              indicate.processMovement(step, C);
              C.canvas.renderAll();
            break;
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
        C.addMoveStepIndicator();
        C.canvas.renderAll();
      });

      /**************************************
           When a model in the server changed
           changes like add step/stage or delete step/stage.
      ***************************************/
      /*this.canvas.on("modelChanged", function(evtData) {
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
