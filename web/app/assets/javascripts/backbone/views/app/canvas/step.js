ChaiBioTech.app.Views = ChaiBioTech.app.Views || {};
ChaiBioTech.app.selectedStep = null;

ChaiBioTech.app.Views.fabricStep = function(model, parentStage, index) {

  this.model = model;
  this.parentStage = parentStage;
  this.index = index;
  this.canvas = parentStage.canvas;
  this.myWidth = 120;

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

  this.render = function() {
    this.setLeft();
    this.addName();
    this.addBorderRight();
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
    this.addSelectionImages();
  }

  this.addSelectionImages = function() {
  //  this.selectionImage = new ChaiBioTech.app.Views.fabricSelectionImage("assets/selected-step-01.png", this, this.canvas);

  }

  this.canvas.on('mouse:down', function(evt) {
    if(evt.target && evt.target.name === "step") {
      var me = evt.target.me;
      if(ChaiBioTech.app.selectedStep) {
        var previouslySelected = ChaiBioTech.app.selectedStep;
        previouslySelected.stepName.fill = "white";
        ChaiBioTech.app.selectedStep = me;
      } else {
        ChaiBioTech.app.selectedStep = me;
      }
      me.canvas.fire("step:selected", evt);
      //Firing this so that parent stage can do the changes
      me.stepName.fill = "black";
    }
  });

  this.canvas.on("image:loaded", function(me) {
    console.log("okay Image Loaded", me);
    me.parent.canvas.add(me.parent.selectionImage);
  })

  return this;
}
