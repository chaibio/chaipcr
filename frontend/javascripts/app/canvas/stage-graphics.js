window.ChaiBioTech.ngApp.factory('stageGraphics', [

  function() {

    this.addRoof = function() {

      this.roof = new fabric.Line([0, 25, (this.myWidth), 25], {
          stroke: 'white', strokeWidth: 2, selectable: false
        }
      );
      return this;
    };

    this.borderLeft = function() {

      this.border =  new fabric.Line([0, 0, 0, 342], {
          stroke: '#ff9f00',  left: 0,  top: 60,  strokeWidth: 2, selectable: false
        }
      );
      return this;
    };

    //This is a special case only for the last stage
    this.addBorderRight = function() {

        this.borderRight = new fabric.Line([0, 0, 0, 342], {
          stroke: '#ff9f00',  left: (this.myWidth + this.left + 2) || 122,  top: 60,  strokeWidth: 2, selectable: false
        }
      );
      this.canvas.add(this.borderRight);
      return this;
    };

    this.writeMyNo= function() {

      var temp = parseInt(this.index) + 1;
      //temp = (temp < 10) ? "0" + temp : temp;

      this.stageNo = new fabric.Text("STAGE " + temp.toString() + ":", {
          fill: 'white',  fontSize: 12, top : 7,  left: 2,  fontFamily: "dinot", selectable: false
        }
      );
      return this;
    };

    this.stageHeader = function() {

      var index = parseInt(this.index) + 1;
      var stageName = (this.model.name).toUpperCase().replace("STAGE", "");
      var text = "STAGE " + index + ":" + stageName;

      if(this.model.stage_type === "cycling") {
        var noOfCycles = this.noOfCycles || this.model.num_cycles;
        noOfCycles = String(noOfCycles);
        text = text + ", " + noOfCycles + "x";
      }
      console.log(text);
      //this.header = new fabric.iText({
      this.stageName.setText(text);
      //});

    };
    this.writeMyName = function() {

      var stageName = (this.model.name).toUpperCase();
      stageName = stageName.replace("STAGE", "");
      this.stageName = new fabric.Text(stageName, {
          fill: 'white', fontWeight: "400",  fontSize: 12,  top : 8, left: 18, fontFamily: "dinot",  selectable: false,
        }
      );
      return this;
    };

    this.writeNoOfCycles = function() {

      this.noOfCycles = this.noOfCycles || this.model.num_cycles;

      this.cycleNo = new fabric.Text(String(this.noOfCycles), {
        fill: 'white',  fontSize: 12, top : 7,  left: 0, fontFamily: "dinot", selectable: false
      });

      this.cycleX = new fabric.Text("x", {
          fill: 'white',  fontSize: 12, top : 16, left: this.cycleNo.width + 5,
          fontFamily: "dinot", selectable: false
        }
      );

      this.cycles = new fabric.Text("CYCLES", {
          fill: 'white',  fontSize: 12, top : 28,
          left: this.cycleX.width + this.cycleNo.width + 10 ,
          fontFamily: "dinot",  selectable: false
        }
      );

      this.cycleGroup = new fabric.Group([this.cycleNo, this.cycleX, this.cycles], {
        originX: "left",  originY: "top",
        left: 120
      });
      return this;
    };

    this.createStageRect = function() {

      this.stageRect = new fabric.Rect({
          left: 0,  top: 0, fill: '#ffb400',  width: this.myWidth,  height: 384,  selectable: false
        }
      );

      return this;
    };

    this.createStageGroup = function(stageContents) {

      this.stageGroup = new fabric.Group(stageContents, {
            originX: "left", originY: "top", left: this.left,top: 0, selectable: false, hasControls: false
          }
      );
      return this;
    };

    return this;
  }
]);
