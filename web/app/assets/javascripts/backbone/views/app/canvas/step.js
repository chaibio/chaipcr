ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};
ChaiBioTech.app.selectedStep = null;

ChaiBioTech.app.Views.fabricStep = function(model, parentStage, index) {

  this.model = model;
  this.parentStage = parentStage;
  this.index = index;
  this.canvas = parentStage.canvas;
  this.myWidth = 120;
  this.nextStep = null;
  this.previousStep = null;

  this.setLeft = function() {
    this.left = this.parentStage.left + 1 + (parseInt(this.index) * this.myWidth);
    //console.log(this.left, this.index);
  }

  this.addName = function() {
    var stepName = (this.model.get("step").name).toUpperCase();
    this.stepName = new fabric.Text(stepName, {
      fill: 'white',
      fontSize: 9,
      top : 45,
      left: this.left + 3,
      fontFamily: "Open Sans",
      selectable: false
    });
  }

  this.addBorderRight = function() {
    this.borderRight = new fabric.Line([0, 0, 0, 342], {
      stroke: '#ff9f00',
      left: this.left + (this.myWidth - 2),
      top: 60,
      strokeWidth: 1,
      selectable: false
    });
  }

  this.addCircle = function() {
    this.circle = new ChaiBioTech.app.Views.fabricCircle(this.model, this);
    this.circle.render();
  }

  this.getUniqueName = function() {
    var name = this.stepName.text + this.parentStage.stageNo.text + "step";
    this.uniqueName = name;
  }

  this.manageBorder = function(color) {
    if(this.borderRight.visible === false) { // Means this is the last step in the stage
      if(this.previousStep) {
        this.previousStep.borderRight.stroke = color;
      } else {
        this.parentStage.border.stroke = color;
      }

      if(this.parentStage.nextStage) {
        this.parentStage.nextStage.border.stroke = color;
      } else {
        this.parentStage.borderRight.stroke = color;
      }
    } else {
      this.borderRight.stroke = color;
      if(this.previousStep) {
        this.previousStep.borderRight.stroke = color;
      } else {
        this.parentStage.border.stroke = color;
      }

      /*if(this.parentStage.nextStage) {
        this.parentStage.nextStage.border.stroke = color;
      } else {
        this.parentStage.borderRight.stroke = color;
      }*/
    }
  }

  this.render = function() {
    this.setLeft();
    this.addName();
    this.addBorderRight();
    this.getUniqueName();
    this.stepRect = new fabric.Rect({
      left: this.left || 30,
      top: 64,
      fill: '#ffb400',
      width: this.myWidth,
      height: 340,
      selectable: false,
      name: "step",
      me: this
    });

    this.canvas.add(this.stepRect);
    this.canvas.add(this.stepName);
    this.canvas.add(this.borderRight);
    this.addCircle();
  }

  this.selectStep = function(evt) {
    var me = (evt.target) ? evt.target.me : this;
    if(ChaiBioTech.app.selectedStep) {
      var previouslySelected = ChaiBioTech.app.selectedStep;
      previouslySelected.darkFooterImage.visible = false;
      previouslySelected.whiteFooterImage.visible = false;
      previouslySelected.manageBorder('#ff9f00');
      //
      ChaiBioTech.app.selectedStep = me;
    } else {
      ChaiBioTech.app.selectedStep = me;
    }
    // Change the border
    me.manageBorder("black");
    me.darkFooterImage.visible = me.whiteFooterImage.visible = true;
    me.commonFooterImage.visible = false;
    //$(".middle-ground").html(me.parentStage.stageNo.text + " " + me.stepName.text + " " + me.parentStage.stageName.text);
  }

  this.canvas.on('mouse:down', function(evt) {
    if(evt.target && evt.target.name === "step") {
      var me = evt.target.me;
      //Using function instead of event, so that everything works synchronous.
      me.parentStage.selectStage(evt, me);
      me.selectStep(evt);
    }
  });
  return this;
}
