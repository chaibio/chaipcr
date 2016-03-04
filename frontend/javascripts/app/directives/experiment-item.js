window.ChaiBioTech.ngApp.directive('experimentItem', [
  '$state',
  '$stateParams',
  function($state, $stateParams){
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        state: '@stateVal',
        lidOpen: '=lidOpen',
        maxCycle: '=maxCycle'
      },
      templateUrl: "app/views/directives/experiment-item.html",
      link: function(scope, elem) {

        scope.runReady = false;
        scope.expID = $stateParams.id;

        scope.$watch('state', function(val) {
          if(val) {
            if(scope.state === "NOT_STARTED") {
              scope.message = "RUN EXPERIMENT";
            } else if(scope.state === "RUNNING") {
              scope.message = "EXPERIMENT STATUS";
            } else if(scope.state === 'COMPLETED') {
              scope.message = "VIEW RESULT";
            }
          }
        });

        scope.manageAction = function() {
          console.log("bingo");
          if(scope.state === "NOT_STARTED") {
            scope.runReady = !scope.runReady;
          } else {
            $state.go('run-experiment', {id: $stateParams.id, chart: 'amplification', max_cycle: scope.maxCycle});
          }
        };

        scope.startExp = function() {
          $state.go('run-experiment', {id: $stateParams.id, chart: 'amplification', max_cycle: scope.maxCycle});
        };
      }
    };
  }
]);
