window.ChaiBioTech.ngApp.factory('stepGraphics', [

  function() {

    this.addName = function() {

      var stepName = (this.model.name) ? (this.model.name).toUpperCase() : "STEP " +(this.index + 1);
      this.stepNameText = stepName;
      this.stepName = new fabric.Text(stepName, {
          fill: 'white',  fontSize: 9,  top : -4,  left: 3,  fontFamily: "Open Sans",  selectable: false,
          originX: 'left', originY: 'top'
        }
      );

      return this;
    };

    this.addBorderRight = function() {

      this.borderRight = new fabric.Line([0, 0, 0, 342], {
          stroke: '#ff9f00',  left: (this.myWidth - 2),  top: 7, strokeWidth: 1, selectable: false,
          originX: 'left', originY: 'top'
        }
      );

      return this;
    };

    this.rampSpeed = function() {

      this.rampSpeedNumber = this.model.ramp.rate;

      this.rampSpeedText = new fabric.Text(String(this.rampSpeedNumber)+ "º C/s", {
          fill: 'black',  fontSize: 14, fontWeight: "bold", fontFamily: "Open Sans",  originX: 'left',  originY: 'top'
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
          fill: '#ffb400',  width: this.myWidth,  height: 340,  selectable: false,  name: "step", me: this
        }
      );

      this.stepGroup = new fabric.Group([this.stepRect, this.stepName, this.borderRight], {
        left: this.left || 32,  top: 44,  selectable: false,  hasControls: false,
        hasBoarders: false, name: "stepGroup",  me: this, originX: 'left', originY: 'top'
      });
    };

    return this;
  }
]);
