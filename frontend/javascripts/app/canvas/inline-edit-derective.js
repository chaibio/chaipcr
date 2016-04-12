angular.module("canvasApp").directive('inlineEdit', [
  'editMode',
  'canvas',
  'previouslySelected',
  function(editMode, canvas, previouslySelected) {
    return {
      restric: 'A',

      link: function($scope, elem) {

        angular.element(window).on('keydown', function(evt) {

            //evt.preventDefault();
          if(editMode.tempActive) {
            //console.log(evt);
            //evt.preventDefault();
            //console.log(evt);
            if(evt.which === 13) {
              evt.preventDefault();
              console.log("Good", previouslySelected);
              //previouslySelected.circle.temperature.trigger('editing:exited');
            }
          }
          //evt.preventDefault();
        });
      }
    };
  }
]);
