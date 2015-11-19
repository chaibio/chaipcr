window.ChaiBioTech.ngApp.directive('scrollOnTop', [
  function() {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/scroll-on-top.html',

      scope: {
        width: "@width"
      },

      link: function(scope, elem, attr) {
        scope.move = 0;
        scope.element = $(".canvas-containing");
        scope.scrollDiff = 0;
        scope.position = 0;
        var bar = $(elem).find(".foreground-bar");

        scope.$watch("width", function(newVal, oldVal) {

          var ratio = (newVal / 1024);
          var width = 300 / ratio;
          var canvasDiff = newVal - 1024;
          scope.scrollDiff = 300 - width;

          scope.move = canvasDiff / scope.scrollDiff;
          // Automatically update
          if(scope.position !== 0) {
              var oldWidth = 300 / (oldVal / 1024);
              var moveLeft = Math.abs(oldWidth - width);
              scope.position = Math.abs(scope.position - moveLeft);
              bar.css("left", scope.position + "px");
              bar.css("width", width + "px");
          }

          bar.css("width", width + "px");
        });

        scope.dragElem = $(elem).find(".foreground-bar").draggable({
          refreshPositions: true,
          containment: "parent",
          axis: "x",

          drag: function(event, ui) {

            if(ui.position.left > 0 && ui.position.left <= scope.scrollDiff) {
              scope.element.scrollLeft(ui.position.left * scope.move);
            }

          },

          stop: function(event, ui) {
            scope.position = ui.position.left;
          }
        });
      }
    };
  }
]);
