angular.module("canvasApp").factory('textChanged', [
  'ExperimentLoader',
  'previouslySelected',
  'previouslyHoverd',
  'scrollService',
  'circleManager',
  'editMode',
  function(ExperimentLoader, previouslySelected, previouslyHoverd, scrollService, circleManager, editMode) {

    /**************************************
      What happens when text:changed event occurs.
    ***************************************/

    this.init = function(C, $scope, that) {
      // that originally points to event. Refer event.js
      var me;

      this.canvas.on('text:changed', function(evt) {
        var Myobj = that.canvas.getActiveObject(), textOriginal = Myobj.getText();

        if(textOriginal.search(/\n/) !== -1) {
          Myobj.text = textOriginal.replace(/(\n)/gm, "");
          console.log("bingo", Myobj.type);
          Myobj.trigger('text:editing:exited');
          C.canvas.renderAll();
        }
      });
    };

    return this;
  }
]);
