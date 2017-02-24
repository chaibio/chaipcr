Circle = () => {
  return {
    create: (properties) => {
      return new fabric.Circle(properties);
    }
  };
};

angular.module('canvasApp').service('Circle', Circle);
