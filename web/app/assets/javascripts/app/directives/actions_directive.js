window.ChaiBioTech.ngApp.directive('actions', [
  'ExperimentLoader',
  '$timeout',
  'canvas',
  function(ExperimentLoader, $timeout, canvas) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/actions.html',

      link: function(scope, elem, attr) {
        scope.actionPopup = false;

        scope.addStep = function() {
          ExperimentLoader.addStep(scope).then(function() {
            scope.reloadAll();
          });
        };

        scope.deleteStep = function() {
          ExperimentLoader.deteStp(scope);
        };

        scope.addStage = function(type) {
          ExperimentLoader.addStage(scope, type);
        };

        scope.reloadAll = function() {
          ExperimentLoader.getExperiment().then(function(data) {
            $scope.protocol = data.experiment;
            canvas.init($scope);
          });
        };
      }
    };
  }
]);
