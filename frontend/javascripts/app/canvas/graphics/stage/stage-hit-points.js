angular.module('canvasApp').factory('hitPoints', [
  'Rectangle',
  function(Rectangle) {
    return {
      createAllHitPoints: function(stage) {
        console.log("I am called", stage);
        var stageHitPointLeftProperties = {
          width: 10, height: 200, fill: '', left: stage.left + 10, top: 10, selectable: false, name: "stageHitPointLeft",
          originX: 'left', originY: 'top', //fill: 'black'
        };

        var stageHitPointRightProperties = {
          width: 10, height: 200, fill: '', left: (stage.left + stage.width) - 20, top: 10, selectable: false, name: "stageHitPointRight",
          originX: 'left', originY: 'top', //fill: 'black'
        };

        var stageHitPointLowerLeftProperties = {
          width: 10, height: 10, fill: '', left: stage.left + 10, top: 340, selectable: false, name: "stageHitPointLowerLeft",
          originX: 'left', originY: 'top', //fill: 'black'
        };

        var stageHitPointLowerRightProperties = {
          width: 10, height: 10, fill: '', left: (stage.left + stage.width) - 20, top: 340, selectable: false, name: "stageHitPointLowerRight",
          originX: 'left', originY: 'top', //fill: 'black'
        };

        var rightPointerDetectorProperties = {
          width: 30, height: 10, fill: '', left: (stage.left + stage.width) + 50, top: 10, selectable: false, name: "rightPointerDetector",
          originX: 'left', originY: 'top', //fill: 'black'
        };

        stage.stageHitPointLeft = Rectangle.create(stageHitPointLeftProperties);
        stage.stageHitPointRight = Rectangle.create(stageHitPointRightProperties);
        stage.stageHitPointLowerLeft = Rectangle.create(stageHitPointLowerLeftProperties);
        stage.stageHitPointLowerRight = Rectangle.create(stageHitPointLowerRightProperties);
        //stage.moveStageRightPointerDetector = Rectangle.create(rightPointerDetectorProperties);

      }
    };
  }
]);
