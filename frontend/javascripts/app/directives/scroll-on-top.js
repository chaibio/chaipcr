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

        scope.$watch("width", function(newVal) {

          var ratio = (newVal / 1024);
          var width = 300 / ratio;
          console.log("newVal", width);
          $(elem).find(".foreground-bar").css("width", width + "px");
        });
        //console.log("hilll", elem);
        scope.dragElem = $(elem).find(".foreground-bar").draggable({
          containment: "parent",
          axis: "x",
        });
      }
    };
  }
]);
