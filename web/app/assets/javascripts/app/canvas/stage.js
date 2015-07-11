window.ChaiBioTech.ngApp.factory('stage', [
  'ExperimentLoader',
  '$rootScope',
  'step',
  function(ExperimentLoader, $rootScope, step) {

    return function(model, stage, allSteps, index, fabricStage, $scope) {

      this.model = model;
      this.index = index;
      this.canvas = stage;
      this.myWidth = this.model.steps.length * 120;
      this.parent = fabricStage;
      this.childSteps = [];
      this.previousStage = this.nextStagenull = this.noOfCycles = null;

      this.addNewStep = function(data) {

        console.log("On the way", data);
        this.myWidth = this.myWidth + 120;
        this.stageRect.width = this.myWidth;

        var currentStage = this;

        while(currentStage.nextStage) {
          currentStage.nextStage.getLeft();
          currentStage.nextStage.stageGroup.set({left: currentStage.nextStage.left }).setCoords();

          var thisStageSteps = currentStage.nextStage.childSteps, stepCount = thisStageSteps.length;

          for(var i = 0; i < stepCount; i++ ) {
            thisStageSteps[i].moveStep();
          }

          currentStage = currentStage.nextStage;
        }
        currentStage.borderRight.set({left: currentStage.myWidth + currentStage.left + 2 });
        this.canvas.renderAll();
      };

      this.getLeft = function() {

        if(this.previousStage) {
          this.left = this.previousStage.left + this.previousStage.myWidth + 2;
        } else {
          this.left = 32;
        }
        return this;
      };

      this.addRoof = function() {

        this.roof = new fabric.Line([0, 0, (this.myWidth - 4), 0], {
            stroke: 'white',  left: 0,  top: 40,  strokeWidth: 2, selectable: false
          }
        );

        return this;
      };

      this.borderLeft = function() {

        this.border = new fabric.Line([0, 0, 0, 342], {
            stroke: '#ff9f00',  left: - 2,  top: 60,  strokeWidth: 2, selectable: false
          }
        );

        return this;
      };

      //This is a special case only for the last stage
      this.borderRight = function() {

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
            fill: 'white',  fontSize: 32, top : 5,  left: 2,  fontFamily: "Ostrich Sans", selectable: false
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
          fill: 'white',  fontSize: 32, top : 5,  fontWeight: "bold", left: 120,  fontFamily: "Ostrich Sans", selectable: false
        });

        this.cycleX = new fabric.Text("x", {
            fill: 'white',  fontSize: 22, top : 15, left: this.cycleNo.width + 120 || 140 + this.cycleNo.width + 120,
            fontFamily: "Ostrich Sans", selectable: false
          }
        );

        this.cycles = new fabric.Text("CYCLES", {
            fill: 'white',  fontSize: 10, top : 28,
            left: this.cycleX.width + this.cycleNo.width + 125 || 140 + this.cycleX.width + this.cycleNo.width + 125,
            fontFamily: "Open Sans",  selectable: false
          }
        );

        return this;
      };

      this.addSteps = function() {

        var steps = this.model.steps, stepView, tempStep = null, noOfSteps = steps.length;
        this.childSteps = [];

        for(var stepIndex = 0; stepIndex < noOfSteps; stepIndex ++) {

          stepView = new step(steps[stepIndex].step, this, stepIndex);

          if(tempStep) {
            tempStep.nextStep = stepView;
            stepView.previousStep = tempStep;
          }

          if(ChaiBioTech.app.newStepId && steps[stepIndex].step.id === ChaiBioTech.app.newStepId) {
            ChaiBioTech.app.newlyCreatedStep = stepView;
            ChaiBioTech.app.newStepId = null;
          }

          tempStep = stepView;
          this.childSteps.push(stepView);
          allSteps.push(stepView);
          stepView.ordealStatus = allSteps.length;
          stepView.render();
        }
        stepView.borderRight.setVisible(false);
      };

      this.findLastStep = function() {

        this.childSteps[this.childSteps.length - 1].circle.doThingsForLast();
      };

      this.render = function() {
          this.getLeft()
          .addRoof()
          .borderLeft()
          .writeMyNo()
          .writeMyName()
          .writeNoOfCycles();

          this.stageRect = new fabric.Rect({
              left: 0,  top: 0, fill: '#ffb400',  width: this.myWidth,  height: 384,  selectable: false
            }
          );
          //this.canvas.add(this.stageRect, this.roof, this.border, this.stageNo, this.stageName);

          if(this.model.stage_type === "cycling" && this.model.steps.length > 1) {

            this.stageGroup = new fabric.Group([
                this.stageRect, this.roof,  this.border,  this.stageNo, this.stageName, this.cycleNo, this.cycleX,  this.cycles
              ], {
                  originX: "left", originY: "top", left: this.left,top: 0, selectable: false, hasControls: false
                }
            );

          } else {

            this.stageGroup = new fabric.Group([
                this.stageRect, this.roof, this.border, this.stageNo, this.stageName
              ], {
                originX: "left",  originY: "top", left: this.left,  top: 0, selectable: false,  hasControls: false
              }
            );

          }

          this.canvas.add(this.stageGroup);
          this.addSteps();
          //this.canvas.renderAll();
      };

      this.manageBordersOnSelection = function(color) {

        this.border.setStroke(color);

        if(this.nextStage) {
          this.nextStage.border.setStroke(color);
        } else {
          this.borderRight.setStroke(color);
        }
      };

      this.manageFooter = function(visible, color, length) {

        for(var i = 0; i< length; i++) {
            this.childSteps[i].commonFooterImage.setVisible(visible);
            this.childSteps[i].stepName.setFill(color);
        }
      };

      this.changeFillsAndStrokes = function(color)  {

        this.roof.setStroke(color);
        this.stageNo.fill = this.stageName.fill = color;
        this.cycleNo.fill = this.cycleX.fill = this.cycles.fill = color;
      };

      this.selectStage =  function() {

        var length = this.childSteps.length;

        if(ChaiBioTech.app.selectedStage) {
          var previouslySelected = ChaiBioTech.app.selectedStage;
          var previousLength = previouslySelected.childSteps.length;

          previouslySelected.changeFillsAndStrokes("white");
          previouslySelected.manageBordersOnSelection("#ff9f00");
          previouslySelected.manageFooter(false, "white", previousLength);
        }

        ChaiBioTech.app.selectedStage = this;
        this.changeFillsAndStrokes("black");
        this.manageBordersOnSelection("#cc6c00");
        this.manageFooter(true, "black", length);
      };


    };

  }
]);
