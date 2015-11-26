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

  function(ExperimentLoader, previouslySelected, popupStatus, previouslyHoverd, scrollService,
    mouseOver, mouseOut, mouseDown, objectMoving, objectModified) {
    return function(C, $scope) {

      this.canvas = C.canvas;
      this.startDrag = 0;
      this.mouseDown = false;
      this.canvasContaining = $('.canvas-containing');
      var that = this;
      console.log("Events loaded .... !", ExperimentLoader);

      mouseOver.init.call(this, C, $scope, that);
      mouseOut.init.call(this, C, $scope, that);
      mouseDown.init.call(this, C, $scope, that);
      objectMoving.init.call(this, C, $scope, that);
      objectModified.init.call(this, C, $scope, that);

      angular.element('.canvas-container, .canvasClass').mouseleave(function() {

        if(C.editStageStatus === false) {
            if(previouslyHoverd.step) {
              previouslyHoverd.step.closeImage.setVisible(false);
            }
            previouslyHoverd.step = null;
            C.canvas.renderAll();
        }
      });

      angular.element('.canvas-containing').click(function(evt) {

        if(evt.target == evt.currentTarget) {
          that.setSummaryMode();
        }
      });

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
            return ((lastStep.left + 3) - 120);
          } else if(moveElement === "stage") {
            return ((lastStep.parentStage.left + 3) - 120);
          }
        }

        return lastStep.left + 3;
      };

      this.onTheMoveDragGroup = function(dragging) {

        var indicator = dragging;
        if(indicator.left < 35) {
          indicator.setLeft(35);
        } else if(indicator.left > C.moveLimit) {
          indicator.setLeft(C.moveLimit);
        } else {
          indicator.setLeft(dragging.left);
          indicator.setCoords();
          indicator.onTheMove(C);
        }
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

      this.canvas.on("mouse:move", function(evt) {

        if(that.mouseDown && evt.target) {

          if(that.startDrag === 0) {
            that.canvas.defaultCursor = "move";
            that.startDrag = evt.e.clientX;
            that.startPos = $(".canvas-containing").scrollLeft();
          }

          var left = that.startPos + (evt.e.clientX - that.startDrag);
          if((left >= 0) && (left <= $scope.scrollWidth - 1024)) {

            $scope.$apply(function() {
              $scope.scrollLeft = left;
            });

            that.canvasContaining.scrollLeft(left);
          }
        }
      });

      this.canvas.on("mouse:up", function(evt) {

        if(that.mouseDown) {
          that.canvas.defaultCursor = "default";
          that.startDrag = 0;
          that.mouseDown = false;
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
        C.addStages().setDefaultWidthHeight().addRampLinesAndCircles();
        C.selectStep();
        //C.addMoveStepIndicator();
        C.canvas.renderAll();
      });
    };
  }
]);
