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
            console.log(val);
            if(val === "cycling") {
              scope.disabled = false;
            } else {
              scope.disabled = true;
            }
          });

        });


      }
    };
  }
]);
