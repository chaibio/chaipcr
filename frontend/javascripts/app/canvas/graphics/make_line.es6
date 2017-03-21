Line = () => {
  return {
    create: (cordinates, properties) => {
      return new fabric.Line(cordinates, properties);
    }
  };
};

angular.module('canvasApp').service('Line', Line);
