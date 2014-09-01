ChaiBioTech.app.Views = ChaiBioTech.app.Views || {}

ChaiBioTech.app.Views.fabricCanvas = function(model) {

  var model = model;

  var canvas = new fabric.Canvas('canvas', {
    backgroundColor: '#ffb400',
    selectionColor: 'green'
  });

  canvas.on("mouse:down", function(options) {
    console.log(options.e.clientX, options.e.clientY);
  });

  var setDefaultWidthHeight = function() {
    canvas.setHeight(420);
    canvas.setWidth(1024);
    canvas.renderAll();
  };

  var addStages = function() {
    var allStages = model.get("experiment").protocol.stages;
    var stage = {};
    var previousStage = null;

    for (stageIndex in allStages) {
      stageModel = new ChaiBioTech.Models.Stage({"stage": allStages[stageIndex].stage});
      stageView = new ChaiBioTech.app.Views.fabricStage(stageModel, canvas, stageIndex);

      if(previousStage){
        previousStage.nextStage = stageView;
        stageView.previousStage = previousStage;
      }

      previousStage = stageView;
      stageView.render();
    }

  };

  return {
    setDefaultWidthHeight: setDefaultWidthHeight,
    addStages: addStages
  }




  // This goes to different part for creating step stage ... !!!
  /*var rect = new fabric.Rect({
    left: 100,
    top: 100,
    fill: 'red',
    width: 20,
    height: 20,
    angle: 45
  });*/

//this.canvas.add(rect);
//canvas.renderAll();
}
