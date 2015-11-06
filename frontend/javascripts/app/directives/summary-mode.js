window.ChaiBioTech.ngApp.directive('summaryMode', [

  function() {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/summary-mode-general.html',
      scope: false,

      link: function(scope, elem, attr) {

        scope.$watch('summaryMode', function(summary) {

          if(! summary) {
            $(".first-data-row").animate({
              left: "0"
            }, 1000);
          }
        });

      }
    };
  }
]);
