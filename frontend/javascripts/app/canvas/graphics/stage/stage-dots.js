angular.module('canvasApp').factory('stageDots', [
  'Group',
  function(Group) {
    return function(_this, dotsArray, editStageStatus) {

      properties = {
        originX: "left", originY: "top", left: _this.left, top: 6, hasControls: false, width: 22, height: 22,
        visible: editStageStatus,parent: _this, name: "moveStage", lockMovementY: true, hasBorders: false,
        selectable: true, backgroundColor: ''
      };


      return Group.create(dotsArray, properties);
    };
  }
]);
