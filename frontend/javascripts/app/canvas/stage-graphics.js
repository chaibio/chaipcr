window.ChaiBioTech.ngApp.factory('stageGraphics', [

  function() {

    this.addRoof = function() {

      this.roof = new fabric.Line([0, 24, (this.myWidth), 24], {
          stroke: 'white', strokeWidth: 2, selectable: false, left: 0
        }
      );
      return this;
    };

    this.borderLeft = function() {

      this.border =  new fabric.Line([0, 70, 0, 390], {
          stroke: '#ff9f00',  left: 0, strokeWidth: 2, selectable: false
        }
      );
      return this;
    };

    this.dotsOnStage = function() {

      var cordiantes = {
        "dot1": [1, 1], "dot2": [12, 1], "dot3": [6.5, 6], "dot4": [1, 10], "dot5": [12, 10],
      }, smallDotArray = [];

      for(var dot in cordiantes) {
        var cord = cordiantes[dot];
        smallDotArray.push(new fabric.Circle({
          radius: 2, fill: 'white', left: cord[0], top: cord[1], selectable: false,
          name: "stageDot", originX: "center", originY: "center"
        }));
      }

      var editStageStatus = this.parent.editStageStatus;

      this.dots = new fabric.Group(smallDotArray, {
        originX: "left", originY: "top", left: 3, top: 8, evented: false, width: 13, height: 12, visible: editStageStatus
      });
      return this;
    };

    this.stageHeader = function() {

      if(this.stageName) {

        var index = parseInt(this.index) + 1;
        var stageName = (this.model.name).toUpperCase().replace("STAGE", "");
        var text = (stageName).trim();
        this.stageCaption.setText("STAGE " + index + ": " );

        if(this.model.stage_type === "cycling") {
          var noOfCycles = this.model.num_cycles;
          noOfCycles = String(noOfCycles);
          text = text + ", " + noOfCycles + "x";
        }

        this.stageName.setText(text);
        this.stageName.setLeft(this.stageCaption.left + this.stageCaption.width);
      }
    };

    this.writeMyName = function() {

      this.stageCaption = new fabric.Text("", {
          fill: 'white', fontWeight: "400",  fontSize: 12,   fontFamily: "dinot-bold",
          originX: "left", originY: "top", selectable: true, left: 0
        }
      );

      this.stageName = new fabric.Text("", {
          fill: 'white', fontWeight: "400",  fontSize: 12,   fontFamily: "dinot",
          originX: "left", originY: "top", selectable: true
        }
      );

      var editStageStatus = this.parent.editStageStatus;
      var addUp = (editStageStatus) ? 26 : 1;

      this.stageNameGroup = new fabric.Group([this.stageCaption, this.stageName], {
        originX: "left", originY: "top", selectable: true, top : 8, left: addUp,
      });
      return this;
    };

    this.createStageRect = function() {

      this.stageRect = new fabric.Rect({
          left: 0,  top: 0, fill: '#FFB300',  width: this.myWidth,  height: 400,  selectable: false
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
