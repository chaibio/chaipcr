ChaiBioTech.app = ChaiBioTech.app || {};

window.ChaiBioTech.ngApp.factory('canvas', [
  'ExperimentLoader',
  '$rootScope',
  'stage',
  '$timeout',
  function(ExperimentLoader, $rootScope, stage, $timeout) {

    var that = this;
    $rootScope.$on('general-data-ready', function(evt) {
      that.$scope = evt.targetScope;
    });

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
      /*
      this.$scope.$watch(function(scope) {
        return scope.step.name
      }, function(newVal, oldVal) {
        console.log(newVal);
      });
      */
      this.imageobjects = {};
      this.canvas = new fabric.Canvas('canvas', {
        backgroundColor: '#ffb400', selection: false, stateful: true
      });

      this.addStages().setDefaultWidthHeight();
    };

    this.setDefaultWidthHeight = function() {

      this.canvas.setHeight(420);
      var width = (this.allStepViews.length * 122 > 1024) ? this.allStepViews.length * 120 : 1024;
      this.canvas.setWidth(width + 50);

      $timeout(function(context) {
        context.canvas.renderAll();
      },100 , true, this);

      return this;
    };

    this.addStages = function() {

      var allStages = this.model.protocol.protocol.stages;
      var previousStage = null, noOfStages = allStages.length, stageView;

      for (var stageIndex = 0; stageIndex < noOfStages; stageIndex ++) {

        stageView = new stage(allStages[stageIndex].stage, this.canvas, this.allStepViews, stageIndex, this);
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
      stageView.borderRight();
      //this.canvas.add(stageView.borderRight);
      // We should put an infinity symbol if the last step has infinite hold time.
      //stageView.findLastStep();
      console.log("Stages added ... !");
      return this;

    };

    return this;

  }
]);
