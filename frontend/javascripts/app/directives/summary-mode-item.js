window.ChaiBioTech.ngApp.directive('summaryModeItem', [
  'ExperimentLoader',
  function(ExperimentLoader) {

    return {
      restric: 'EA',
      replace: true,
      scope: {
        caption: "@",
        reading: '@'
      },

      templateUrl: 'app/views/directives/summary-mode-item.html',


      link: function(scope, elem, attr) {


        if(scope.caption.length > 15) {
          $(elem).find(".caption-part").css("font-size", "14px");
        }

        scope.delta = true;
        scope.date = false;
        scope.$watch("reading", function(val) {
          scope.data = scope.reading;

          if(angular.isDefined(scope.reading)) {
            if(scope.caption === "Created on") {
              scope.date = true;
              //timeFormat.getForSummaryMode(scope.reading);
              //scope.data = (scope.reading).replace("T", ",").slice(0, -8);
            }
          }

        });

      }
    };
  }
]);
