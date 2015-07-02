ChaiBioTech.app = ChaiBioTech.app || {};

window.ChaiBioTech.ngApp.factory('canvas', [
  'ExperimentLoader',
  '$rootScope',
  'stage',
  function(ExperimentLoader, $rootScope, stage) {

    this.init = function(model) {
        this.model = model;
        this.allStepViews = [];
        this.allStageViews = [];
        this.canvas = null;
        this.allCircles = null;
        this.images = [
          "common-step.png",
          "black-footer.png",
          "orange-footer.png",
          "gather-data.png",
          "gather-data-image.png"
        ];

        this.imageobjects = {};
        this.canvas = new fabric.Canvas('canvas', {
          backgroundColor: '#ffb400',
          selection: false,
          stateful: true
        });

        this.addStages().setDefaultWidthHeight();
    };

    this.setDefaultWidthHeight = function() {

      this.canvas.setHeight(420);
      var width = (/*this.allStepViews.length*/ 3 * 122 > 1024) ? /*this.allStepViews.length*/ 3 * 120 : 1024;
      this.canvas.setWidth(width + 50);
      this.canvas.renderAll();
      return this;
    };

    this.addStages = function() {
      //console.log("cool", stage, $rootScope);
      var allStages = this.model.protocol.protocol.stages;
      var previousStage = null, noOfStages = allStages.length;

      for (var stageIndex = 0; stageIndex < noOfStages; stageIndex ++) {

        var stageModel = allStages[stageIndex].stage;
        var stageView = new stage(stageModel, this.canvas, this.allStepViews, stageIndex, this);
        // We connect the stages like a linked list so that we can go up and down.
        if(previousStage){
          previousStage.nextStage = stageView;
          stageView.previousStage = previousStage;
        }

        previousStage = stageView;
        stageView.render();
        this.allStageViews.push(stageView);
      }
      // Only for the last stage
      //stageView.borderRight();
      //this.canvas.add(stageView.borderRight);
      // We should put an infinity symbol if the last step has infinite hold time.
      //stageView.findLastStep();
      console.log("Stages added ... !");
      return this;

    };

    return this;

  }
]);
