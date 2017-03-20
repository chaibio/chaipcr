angular.module('canvasApp').factory('stageGroup', [
  'Group',
  function(Group) {
    return function(stageContents, left) {
      var properties = {
            originX: "left", originY: "top", left: left,top: 0, selectable: false, hasControls: false
          };

        return Group.create(stageContents, properties);
    };
  }
]);
