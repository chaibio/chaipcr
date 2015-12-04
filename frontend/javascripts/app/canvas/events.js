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
  'previouslyHoverd',
  'scrollService',
  'mouseOver',
  'mouseOut',
  'mouseDown',
  'objectMoving',
  'objectModified',
  'mouseMove',
  'mouseUp',
  'htmlEvents',
  'circleManager',

  function(ExperimentLoader, previouslySelected, popupStatus, previouslyHoverd, scrollService,
    mouseOver, mouseOut, mouseDown, objectMoving, objectModified, mouseMove, mouseUp, htmlEvents,
    circleManager) {
    return function(C, $scope) {

      this.canvas = C.canvas;
      this.startDrag = 0; // beginning position of dragging
      this.mouseDown = false;
      var that = this;

      // Initiate all events
      mouseOver.init.call(this, C, $scope, that);
      mouseOut.init.call(this, C, $scope, that);
      mouseDown.init.call(this, C, $scope, that);
      mouseMove.init.call(this, C, $scope, that);
      mouseUp.init.call(this, C, $scope, that);

      objectMoving.init.call(this, C, $scope, that);
      objectModified.init.call(this, C, $scope, that);

      htmlEvents.init.call(this, C, $scope, that);

      // Methods
      this.setSummaryMode = function() {

        $scope.$apply(function() {
          $scope.summaryMode = true;
        });
        var circle = previouslySelected.circle;
        circle.parent.unSelectStep();
        circle.parent.parentStage.unSelectStage();
        circle.makeItSmall();
        C.canvas.renderAll();
      };

      this.selectStep = function(circle) {

        $scope.summaryMode = false;
        circle.manageClick();
        $scope.applyValuesFromOutSide(circle);
      };

      this.containInfiniteStep = function(step) {

        var stage = step.parentStage;
        if(stage.next) {
          return false;
        }

        var lastOne = stage.childSteps[stage.childSteps.length - 1];
        if(lastOne.circle.holdTime.text === "∞") {
          return true;
        }

        return false;
      };

      this.infiniteStep =  function(step) {

        if(step.circle.holdTime.text === "∞") {
          return true;
        }
        return false;

      };

      this.calculateMoveLimit = function(moveElement) {

        var lastStep = C.allStepViews[C.allStepViews.length - 1];

        if(lastStep.circle.holdTime.text === "∞") {
          if(moveElement === "step") {
            C.moveLimit = ((lastStep.left + 3) - 120);
          } else if(moveElement === "stage") {
            C.moveLimit = ((lastStep.parentStage.left + 3) - 120);
          }
        }

         C.moveLimit = lastStep.left + 3;
      };

      this.onTheMoveDragGroup = function(dragging) {

        C.stepIndicator.setLeft(dragging.left);
        C.stepIndicator.setCoords();
        /*var indicator = dragging;
        if(indicator.left < 35) {
          indicator.setLeft(35);
        } else if(indicator.left > C.moveLimit) {
          indicator.setLeft(C.moveLimit);
        } else {
          indicator.setLeft(dragging.left);
          indicator.setCoords();
          indicator.onTheMove(C);
        }*/
      };

      this.footerMouseOver = function(indicate, me, moveElement) {

        indicate.changeText(me.parentStage.index, me.index);
        indicate.currentStep = me;
        C.moveLimit = that.calculateMoveLimit(moveElement);
        C.canvas.bringToFront(indicate);
        indicate.setLeft(me.left + 4);
        indicate.setCoords();
        indicate.setVisible(true);
        C.canvas.renderAll();

      };

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
        C.addStages().setDefaultWidthHeight();
        circleManager.addRampLinesAndCircles();
        C.selectStep();
        C.canvas.renderAll();
      });
    };
  }
]);
