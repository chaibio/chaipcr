window.ChaiBioTech.ngApp.directive('summaryMode', [
  'ExperimentLoader',
  function(ExperimentLoader) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/summary-mode-general.html',
      scope: false,

      link: function(scope, elem, attr) {

        scope.$watch('summaryMode', function(summary) {

          if(! summary) {
            $(".data-box-container-summary-scroll").animate({
              left: "0"
            }, 500);

            $(".first-data-row").animate({
              left: "0"
            }, 500);



          } else {
            ExperimentLoader.getExperiment()
              .then(function(data) {
                var estimateTime = data.experiment.protocol.estimate_duration;
                scope.protocol.protocol.estimate_duration = estimateTime;
              });

            $(".data-box-container-summary-scroll").animate({
              left: "-=645"
            }, 500);

            $(".first-data-row").animate({
              left: "-=900"
            }, 500);


          }
        });

      }
    };
  }
]);
