angular.module('canvasApp').factory('stageNameGroup', [
  'Group',
  'stageCaption',
  'stageName',
  function(Group, stageCaption, stageName) {
    return function(step) {

      var editStageStatus = step.parent.editStageStatus;
      var addUp = (editStageStatus === true) ? 26 : 1;
      var moved = (editStageStatus === true) ? "right": false;

      step.stageCaption = new stageCaption();
      step.stageName = new stageName();

      properties = {
        originX: "left", originY: "top", selectable: true, top : 8, left: addUp, moved: moved
      };

      return new Group.create([step.stageCaption, step.stageName], properties);
    };
  }
]);
