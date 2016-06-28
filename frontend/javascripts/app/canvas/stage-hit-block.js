angular.module("canvasApp").factory("stageHitBlock", [
  'ExperimentLoader',
  'previouslySelected',
  'circleManager',
  function(ExperimentLoader, previouslySelected, circleManager) {

    return {

      getStageHitBlock: function(me) {

        this.hitBlock = new fabric.Rect({
          width: 64, height: 10, left: 100, top: 330,
          hasControls: false, selectable: false, visible: false
        });

        return this.hitBlock;
      },
    }
  }
]);
