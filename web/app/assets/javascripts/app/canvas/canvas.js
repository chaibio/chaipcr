ChaiBioTech.app = ChaiBioTech.app || {};

window.ChaiBioTech.ngApp.factory('canvas', [
  'ExperimentLoader',
  '$rootScope',
  'stage',
  function(ExperimentLoader, $rootScope, stage) {

    this.init = function(model) {
        this.model = model;
        this.allStepViews = new Array();
        this.allStageViews = new Array();
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

        this.addStages();
    }

    this.addStages = function() {
      //console.log("cool", stage, $rootScope);
      var xx =  new stage("Jossie");
      //console.log(xx)
      xx.init();
    }

    return this;

  }
]);
