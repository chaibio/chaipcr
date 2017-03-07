Rectangle = () => {
  return {
    create: (properties) => {
      return new fabric.Rect(properties);
    }
  };
};

angular.module('canvasApp').service('Rectangle', Rectangle);
