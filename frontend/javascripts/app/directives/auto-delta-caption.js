window.ChaiBioTech.ngApp.directive('autoDeltaCaption', [
  function() {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/auto-delta-caption.html',

      scope: {
        data: '=data',
        type: '@',
        call: "@"
      },

      link: function(scope, elem, attr) {

        scope.$on("dataLoaded", function() {

          scope.$watch("type", function(val, oldVal) {

            if(val === "cycling") {
              scope.show = true;
            } else {
              scope.show = false;
            }
          });

        });


      }
    };
  }
]);
