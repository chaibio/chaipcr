angular.module('canvasApp').factory('stageNameGroup', [
  'Group',
  function(Group) {
    return function(objects, addUp, moved) {
      properties = {
        originX: "left", originY: "top", selectable: true, top : 8, left: addUp, moved: moved
      };

      return new Group.create(objects, properties);
    };
  }
]);
