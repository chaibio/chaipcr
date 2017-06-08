angular.module('canvasApp').factory('stageDots', [
  'Group',
  'stageDotsBackground',
  'dots',
  function(Group, stageDotsBackground, dots) {
    return function(_this) {

      var dotsArray = dots.stageDots();
      var editStageStatus = _this.parent.editStageStatus;
      dotsArray.unshift(new stageDotsBackground());

      var properties = {
        originX: "left", originY: "top", left: _this.left, top: 6, hasControls: false, width: 22, height: 22,
        visible: editStageStatus, parent: _this, name: "moveStage", lockMovementY: true, hasBorders: false,
        selectable: true, backgroundColor: ''
      };
      
      return Group.create(dotsArray, properties);
    };
  }
]);
