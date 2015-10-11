window.ChaiBioTech.ngApp.factory('stageGraphics', [

  function() {

    this.addRoof = function() {

      this.roof = new fabric.Line([0, 40, (this.myWidth - 4), 40], {
          stroke: 'white', strokeWidth: 2, selectable: false
        }
      );
      return this;
    };

    this.borderLeft = function() {

      this.border =  new fabric.Line([0, 0, 0, 342], {
          stroke: '#ff9f00',  left: - 2,  top: 60,  strokeWidth: 2, selectable: false
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
      temp = (temp < 10) ? "0" + temp : temp;

      this.stageNo = new fabric.Text(temp, {
          fill: 'white',  fontSize: 32, top : 7,  left: 2,  fontFamily: "Ostrich Sans", selectable: false
        }
      );
      return this;
    };

    this.writeMyName = function() {

      var stageName = (this.model.name).toUpperCase();
      this.stageName = new fabric.Text(stageName, {
          fill: 'white',  fontSize: 9,  top : 28, left: 25, fontFamily: "Open Sans",  selectable: false,
        }
      );
      return this;
    };

    this.writeNoOfCycles = function() {

      this.noOfCycles = this.noOfCycles || this.model.num_cycles;

      this.cycleNo = new fabric.Text(String(this.noOfCycles), {
        fill: 'white',  fontSize: 32, top : 7,  fontWeight: "bold",  left: 0, fontFamily: "Ostrich Sans", selectable: false
      });

      this.cycleX = new fabric.Text("x", {
          fill: 'white',  fontSize: 22, top : 16, left: this.cycleNo.width + 5,
          fontFamily: "Ostrich Sans", selectable: false
        }
      );

      this.cycles = new fabric.Text("CYCLES", {
          fill: 'white',  fontSize: 10, top : 28,
          left: this.cycleX.width + this.cycleNo.width + 10 ,
          fontFamily: "Open Sans",  selectable: false
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
