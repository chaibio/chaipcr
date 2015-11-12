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
        scope.position = null;
        scope.$watch("width", function(newVal, oldVal) {

          var ratio = (newVal / 1024);
          var width = 300 / ratio;
          var canvasDiff = newVal - 1024;
          scope.scrollDiff = 300 - width;

          scope.move = canvasDiff / scope.scrollDiff;
          // Automatically update
          if(scope.position) {
              var oldWidth = 300 / (oldVal / 1024);
              var moveLeft = (oldWidth - width) / 2;
              //$(elem).find(".foreground-bar").css("left", scope.scrollDiff + "px");
          } else {
            $(elem).find(".foreground-bar").css("width", width + "px");
          }

          //$(elem).find(".foreground-bar").css("left", scope.scrollDiff + "px");
          //console.log(scrollDiff, canvasDiff, scope.move);
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
            console.log(ui);
            scope.position = ui.position;
          }
        });
      }
    };
  }
]);
