window.ChaiBioTech.ngApp.directive('scrollOnTop', [
  function() {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/scroll-on-top.html',

      scope: {

      },

      link: function(scope, elem, attr) {

        //console.log("hilll", elem);
        scope.dragElem = $(elem).find(".foreground-bar").draggable({
          containment: "parent",
          axis: "x",
        });
      }
    };
  }
]);
