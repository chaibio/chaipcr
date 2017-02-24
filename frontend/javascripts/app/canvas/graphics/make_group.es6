Group = () => {
  return {
    create: (contentArray, properties) => {
      return new fabric.Group(contentArray, properties);
    }
  };
};

angular.module('canvasApp').service('Group', Group);
