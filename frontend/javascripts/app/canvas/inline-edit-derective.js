angular.module("canvasApp").directive('inlineEdit', [
  'editMode',
  'canvas',
  function(editMode, canvas) {
    return {
      restric: 'A',

      link: function($scope, elem) {

        angular.element(window).on('keydown', function(evt) {
          if(editMode.tempActive) {
            console.log(canvas.$scope);
          }
          //evt.preventDefault();
        });
      }
    };
  }
]);
