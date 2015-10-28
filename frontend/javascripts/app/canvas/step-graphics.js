window.ChaiBioTech.ngApp.factory('stepGraphics', [

  function() {

    this.addName = function() {

      var stepName = "Step " +(this.index + 1);
      if(this.model.name) {
        stepName = (this.model.name).charAt(0).toUpperCase() + (this.model.name).slice(1).toLowerCase();
      }

      this.stepNameText = stepName;
      this.stepName = new fabric.Text(stepName, {
          fill: 'white',  fontSize: 12,  top : 20,  left: -1,  fontFamily: "dinot",  selectable: false,
          originX: 'left', originY: 'top'
        }
      );

      return this;
    };

    this.numberingValue = function() {

      var thisIndex = (this.index < 9) ? "0" + (this.index + 1) : (this.index + 1),
      noofSteps = this.parentStage.model.steps.length;
      thisLength = (noofSteps < 10) ? "0" + noofSteps : noofSteps;
      text = thisIndex + "/" + thisLength;

      this.numberingText.setText(text);
      return this;
    };

    this.initNumberText = function() {

      this.numberingText = new fabric.Text('wow', {
          fill: 'white',  fontSize: 12,  top : 7,  left: -1,  fontFamily: "dinot",  selectable: false,
          originX: 'left', originY: 'top'
        }
      );
    };

    this.addBorderRight = function() {

      this.borderRight = new fabric.Line([-2, 42, -2, 362], {
          stroke: '#ff9f00',  left: (this.myWidth - 2), strokeWidth: 1, selectable: false,
          originX: 'left', originY: 'top'
        }
      );

      return this;
    };

    this.rampSpeed = function() {

      this.rampSpeedNumber = this.model.ramp.rate;

      this.rampSpeedText = new fabric.Text(String(this.rampSpeedNumber)+ "º C/s", {
          fill: 'black',  fontSize: 12, fontFamily: "dinot",  originX: 'left',  originY: 'top'
        }
      );

      this.underLine = new fabric.Line([0, 0, this.rampSpeedText.width, 0], {
          stroke: "#ffde00",  strokeWidth: 2, originX: 'left',  originY: 'top', top: 13,  left: 0
        }
      );

      this.rampSpeedGroup = new fabric.Group([
            this.rampSpeedText, this.underLine
          ], {
              selectable: true, hasControls: true,  originX: 'left',  originY: 'top', top : 0,  left: this.left + 5, evented: false
            }
      );

      if(this.rampSpeedNumber <= 0) {
        this.rampSpeedGroup.setVisible(false);
      }

      return this;
    };

    this.stepComponents = function() {

      this.hitPoint = new fabric.Rect({
        width: 10, height: 30, fill: '', left: this.left + 60, top: 335, selectable: false, name: "hitPoint",
        originX: 'left', originY: 'top',
      });

      this.stepRect = new fabric.Rect({
          fill: 'green',  width: this.myWidth,  height: 363,  selectable: false,  name: "step", me: this
        }
      );

      this.stepGroup = new fabric.Group([this.stepRect, this.numberingText, this.stepName, this.borderRight], {
        left: this.left || 33,  top: 28,  selectable: false,  hasControls: false,
        hasBoarders: false, name: "stepGroup",  me: this, originX: 'left', originY: 'top'
      });
    };

    return this;
  }
]);
