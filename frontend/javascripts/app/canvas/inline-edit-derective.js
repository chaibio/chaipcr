angular.module("canvasApp").directive('inlineEdit', [
  'editMode',
  function(editMode) {
    return {
      restric: 'A',

      link: function($scope, elem) {

        angular.element(window).on('keydown', function(evt) {
          console.log($scope);
          evt.preventDefault();
        });
      }
    };
  }
]);
