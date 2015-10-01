window.ChaiBioTech.ngApp.factory('circle', [
  'ExperimentLoader',
  '$rootScope',
  'constants',
  'circleGroup',
  'outerMostCircle',
  'outerCircle',
  'centerCircle',
  'littleCircleGroup',
  'circleMaker',
  'stepDataGroup',
  'stepTemperature',
  'stepHoldTime',
  'gatherDataGroupOnScroll',
  'gatherDataCircleOnScroll',
  'gatherDataGroup',
  'gatherDataCircle',
  'previouslySelected',
  'pauseStepOnScrollGroup',
  'pauseStepCircleOnScroll',

  function(ExperimentLoader, $rootScope, Constants, circleGroup, outerMostCircle, outerCircle,
    centerCircle, littleCircleGroup, circleMaker, stepDataGroup, stepTemperature, stepHoldTime,
    gatherDataGroupOnScroll, gatherDataCircleOnScroll, gatherDataGroup, gatherDataCircle, previouslySelected,
    pauseStepOnScrollGroup, pauseStepCircleOnScroll) {
    return function(model, parentStep) {

      this.model = model;
      this.parent = parentStep;
      this.canvas = parentStep.canvas;
      this.scrollTop = 80;
      this.scrollLength = 317;
      this.halfway = (this.scrollLength - this.scrollTop) / 2;
      //this.scrollRatio = (this.scrollLength - this.scrollTop) / 100;
      this.scrollRatio1 = ((this.scrollLength - this.scrollTop) * 0.25) / 50; // 1.2;//(this.scrollLength - this.scrollTop) / 200;
      this.scrollRatio2 = ((this.scrollLength - this.scrollTop) * 0.75) / 50;//3.54;//(this.scrollLength - this.scrollTop) / 50;
      this.middlePoint = this.scrollLength - ((this.scrollLength - this.scrollTop) * 0.25); // This is the point where it reads 50

      this.gatherDataImage = this.next = this.previous = null;
      this.big = false;
      this.controlDistance = Constants.controlDistance;

      this.getLeft = function() {

        this.left = this.parent.left;
        return this;
      };

      this.getTop = function() {

        var temperature = this.model.temperature;

        if(temperature <= 50) {
          this.top = this.scrollLength - (temperature * this.scrollRatio1);
          return this;
        }

        this.top = ((this.scrollRatio2 * 100) + this.scrollTop) - (temperature * this.scrollRatio2);
        return this;
      };

      this.moveCircle = function() {
        this.getLeft();
        this.getTop();
      };

      this.setCenter = function(imgObj) {
        imgObj.originX = imgObj.originY = "center";
      };

      this.addImages = function() {

        var fabricStage = this.parent.parentStage.parent;
        // This is the image shows in the left, when gather data during ramp is enabled
        this.gatherDataImage = $.extend({}, fabricStage.imageobjects["gather-data.png"]);
        this.setCenter(this.gatherDataImage);

        this.gatherDataImageOnMoving = $.extend({}, fabricStage.imageobjects["gather-data-image.png"]);
        this.setCenter(this.gatherDataImageOnMoving);

        this.gatherDataImageMiddle = $.extend({}, fabricStage.imageobjects["gather-data.png"]);
        this.setCenter(this.gatherDataImageMiddle);
        this.gatherDataImageMiddle.setVisible(false);

        this.pauseImage = $.extend({}, fabricStage.imageobjects["pause.png"]);
        this.setCenter(this.pauseImage);

        this.pauseImageMiddle = $.extend({}, fabricStage.imageobjects["pause.png"]);
        this.setCenter(this.pauseImageMiddle);
        this.pauseImageMiddle.setVisible(false);

        return this;
      };

      this.removeContents = function() {

        this.canvas.remove(this.stepDataGroup);
        this.canvas.remove(this.curve);
        this.canvas.remove(this.gatherDataOnScroll);
        this.canvas.remove(this.circleGroup);
        this.canvas.remove(this.gatherDataGroup);

      };
      /*******************************************
        This method shows circles and gather data. Pease note
        this method is invoked from canvas.js once all the stage/step are loaded.
      ********************************************/
      this.getCircle = function() {

        this.stepDataGroup.set({"left": this.left + 60}).setCoords();
        this.canvas.add(this.stepDataGroup);

        this.gatherDataCircleOnScroll = new gatherDataCircleOnScroll();
        this.gatherDataOnScroll = new gatherDataGroupOnScroll(
          [
            this.gatherDataCircleOnScroll,
            this.gatherDataImageOnMoving,
          ], this);

          this.pauseStepCircleOnScroll = new pauseStepCircleOnScroll();
          this.pauseStepOnScrollGroup = new pauseStepOnScrollGroup(
            [
              this.pauseStepCircleOnScroll,
              this.pauseImage,
            ], this);

        // enable this when image is added on creating new circle ..
        this.circleGroup.set({"left": this.left + 60}).setCoords();

        this.circleGroup.add(this.gatherDataImageMiddle);
        this.circleGroup.add(this.pauseImageMiddle);
        this.circleGroup.add(this.gatherDataOnScroll);
        this.circleGroup.add(this.pauseStepOnScrollGroup);
        this.canvas.add(this.circleGroup);

        this.gatherDataCircle = new gatherDataCircle();
        this.gatherDataGroup = new gatherDataGroup(
          [
            this.gatherDataCircle = new gatherDataCircle(),
            this.gatherDataImage
          ], this);

        this.gatherDataGroup.set({"left": this.left}).setCoords();
        this.canvas.add(this.gatherDataGroup);
        this.showHideGatherData(this.parent.gatherDataDuringStep);
        this.controlPause(this.model.pause);
        if( this.parent.index !== 0 || this.parent.parentStage.index !== 0) {
          this.gatherDataGroup.setVisible(this.parent.gatherDataDuringRamp);
        }

      };

      this.getUniqueId = function() {

        this.uniqueName = this.model.id + this.parent.parentStage.stageNo.text + "circle";
        return this;
      };

      this.doThingsForLast = function() {

        var holdTimeText = this.parent.holdDuration || this.model.hold_time;

        if(parseInt(holdTimeText) === 0) {
          this.holdTime.text = "∞";
        }
      };

      this.changeHoldTime = function() {

        var duration = Number(this.model.hold_time);
        var holdTimeHour = Math.floor(duration / 60);
        var holdTimeMinute = (duration % 60);

        if(holdTimeMinute < 10) {
          holdTimeMinute = "0" + holdTimeMinute;
        }

        this.holdTime.text = holdTimeHour + ":" + holdTimeMinute;
      };

      this.render = function() {

        //this.getLeft().getTop().getUniqueId();

        this.circleGroup = new circleGroup(
          [
            this.outerMostCircle = new outerMostCircle(),
            this.outerCircle = new outerCircle(),
            this.circle = new centerCircle(),
            this.littleCircleGroup = new littleCircleGroup(
              [
                this.littleCircle1 = new circleMaker(-10),
                this.littleCircle2 = new circleMaker(-2),
                this.littleCircle3 = new circleMaker(6)
              ]
            )
          ], this);
        // adjust the placing of ramp speed, this method calculates the top
        this.parent.adjustRampSpeedLeft().adjustRampSpeedPlacing();

        this.stepDataGroup = new stepDataGroup([
            this.temperature = new stepTemperature(this.model, this),
            this.holdTime = new stepHoldTime(this.model, this)
          ], this);

      };

      this.makeItBig = function() {

        this.big = true;

        if(this.model.collect_data) {
          this.circle.setFill("#ffb400;");
          this.gatherDataImageMiddle.setVisible(false);
          this.gatherDataOnScroll.setVisible(true);
        }

        if(this.model.pause) {
          this.circle.setFill("#ffb400");
          this.pauseImageMiddle.setVisible(false);
          this.pauseStepOnScrollGroup.setVisible(true);
        }

        this.circle.setStroke("#ffb400");
        this.outerCircle.setStroke("black");
        this.outerCircle.strokeWidth = 7;
        //this.stepDataGroup.setVisible(false); // Change temperature display
        this.outerMostCircle.visible = this.littleCircleGroup.visible = true;
      };

      this.makeItSmall = function() {

        this.big = false;

        this.circle.setStroke("white");
        this.circle.setFill('#ffb400');
        this.circle.radius = 13;
        this.circle.strokeWidth = 10;
        this.outerCircle.setStroke(null);
        this.stepDataGroup.setVisible(true);
        this.littleCircleGroup.visible = this.outerMostCircle.visible = false;

        if(this.model.collect_data) {
          this.circle.setFill("white");
          this.gatherDataImageMiddle.setVisible(true);
          this.gatherDataOnScroll.setVisible(false);
        }

        if(this.model.pause) {
          this.applyPauseChanges();
        }

      };

      this.applyPauseChanges = function() {

        this.circle.setFill("#ffb400");
        this.circle.setStroke("#ffde00");
        this.circle.strokeWidth = 5;
        this.circle.radius = 18;
        this.pauseImageMiddle.setVisible(true);
        this.gatherDataImageMiddle.setVisible(false);
        this.pauseStepOnScrollGroup.setVisible(false);
      };

      this.showHideGatherData = function(state) {

        if(state && ! this.big) {
            this.gatherDataImageMiddle.setVisible(state);
            this.circle.setFill("white");

        } else {
          this.circle.setFill("#ffb400");
          this.gatherDataOnScroll.setVisible(state);
        }
      };

      this.controlPause = function(state) {

        if(state && this.big) {
          this.pauseStepOnScrollGroup.setVisible(true);
          this.holdTime.setVisible(false);
          return;
        } else if(state) {
          this.holdTime.setVisible(false);
          this.applyPauseChanges();
          return;
        } else {
          this.pauseStepOnScrollGroup.setVisible(false);
          this.holdTime.setVisible(true);
        }
      };

      this.manageDrag = function(targetCircleGroup) {

        var top = targetCircleGroup.top;
        var left = targetCircleGroup.left;
        var previousTop = 0;

        if(top < this.scrollTop) {
          targetCircleGroup.setTop(this.scrollTop);
          this.manageRampLineMovement(left, this.scrollTop, targetCircleGroup);
        } else if(top > this.scrollLength) {
          targetCircleGroup.setTop(this.scrollLength);
          this.manageRampLineMovement(left, this.scrollLength, targetCircleGroup);
        } else {
          this.stepDataGroup.setTop(top + 58);
          this.manageRampLineMovement(left, top, targetCircleGroup);
        }
      };

      this.manageRampLineMovement = function(left, top, targetCircleGroup) {

        var endPointX, endPointY, midPointX, midPointY, dynamicTemp;
        if(this.next) {
            this.curve.path[0][1] = left;
            this.curve.path[0][2] = top;
            // Calculating the mid point of the line at the right side of the circle
            // Remeber take the point which is static at the other side
            endPointX = this.curve.path[2][3];
            endPointY = this.curve.path[2][4];

            midPointX = (left + endPointX) / 2;
            midPointY = (top + endPointY) / 2;
            previousTop  = midPointY;

            this.curve.path[1][1] = left + this.controlDistance;
            this.curve.path[1][2] = top;

            // Mid point
            this.curve.path[1][3] = midPointX;
            this.curve.path[1][4] = midPointY;

            // We move the gather data Circle along with it [its next object's]
            this.next.gatherDataGroup.setTop(midPointY);

            // Controlling point for the next bent
            this.curve.path[2][1] = endPointX - this.controlDistance;
            this.curve.path[2][2] = endPointY;
        }

        if(this.previous) {
            previous = this.previous;
            previous.curve.path[2][3] = left;
            previous.curve.path[2][4] = top;
            // Calculating the mid point of the line at the left side of the cycle
            // Remeber take the point which is static at the other side
            endPointX = previous.curve.path[0][1];
            endPointY = previous.curve.path[0][2];

            midPointX = (left + endPointX) / 2;
            midPointY = (top + endPointY) / 2;

            previous.curve.path[2][1] = left - this.controlDistance;
            previous.curve.path[2][2] = top;

            // Mid point
            previous.curve.path[1][3] = midPointX;
            previous.curve.path[1][4] = midPointY;

            // We move the gather data Circle along with it
            // Please pay attention here we move gatherdta of this
            this.gatherDataGroup.setTop(midPointY);

            if(this.model.ramp.collect_data) {
              this.gatherDataGroup.setCoords();
              this.parent.rampSpeedGroup.setCoords();
              if(this.gatherDataGroup.intersectsWithObject(this.parent.rampSpeedGroup)) {
                /*var boo;
                if(this.gatherDataGroup.top > this.parent.rampSpeedGroup.top) {
                  boo = (this.gatherDataGroup.top - this.parent.rampSpeedGroup.top) - this.parent.rampSpeedGroup.height;
                } else {
                  boo = (this.parent.rampSpeedGroup.top - this.gatherDataGroup.top);
                }

                var val = Math.sqrt(Math.abs((boo * boo) - 256));
                this.parent.rampSpeedGroup.left = this.parent.left + val;
                console.log(boo, "val:", val);*/
                this.parent.rampSpeedGroup.left = this.parent.left + 16;
              } else {
                this.parent.rampSpeedGroup.left = this.parent.left + 5;
              }
            }

            previous.curve.path[1][1] = endPointX + this.controlDistance;
            previous.curve.path[1][2] = endPointY;

        }

        if(targetCircleGroup.top >= this.middlePoint) {
          dynamicTemp = 50 - ((targetCircleGroup.top - this.middlePoint) / this.scrollRatio1);
        } else {
          dynamicTemp = 100 - ((targetCircleGroup.top - this.scrollTop) / this.scrollRatio2);
        }
        // Change temperature display as its circle is moved
        //var dynamicTemp = Math.abs((100 - ((targetCircleGroup.top - this.scrollTop) / this.scrollRatio)));

        dynamicTemp = Math.abs(dynamicTemp).toFixed(1);//(dynamicTemp < 100) ? dynamicTemp.toFixed(1) : dynamicTemp;
        this.temperature.text = String(dynamicTemp + "º");
        this.model.temperature = String(dynamicTemp);
        this.parent.adjustRampSpeedPlacing();
      };

      this.manageClick = function() {

        this.makeItBig();
        this.parent.parentStage.selectStage();
        this.parent.selectStep();

        if(previouslySelected.circle) {
          var previousSelected = previouslySelected.circle;

          if(previousSelected.uniqueName != this.uniqueName) {

            previousSelected.makeItSmall();
          }
        }
        //ChaiBioTech.app.selectedCircle = this;
        previouslySelected.circle = this;
        this.canvas.renderAll();
      };

    };
  }
]);
