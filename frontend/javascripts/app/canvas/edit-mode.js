angular.module("canvasApp").service('editMode', [
  function() {
    return {
      tempActive: false,
      holdActive: false
    };
  }
]);
