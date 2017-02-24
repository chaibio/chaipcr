Text = () => {
  return {
    create: (dataString, properties) => {
      return new fabric.Text(dataString, properties);
    }
  };
};

angular.module('canvasApp').service('Text', Text);
