window.ChaiBioTech.ngApp.directive('general', [
  'ExperimentLoader',
  function(ExperimentLoader) {

    return {
      restric: 'EA',
      replace: true,
      scope: false,
      templateUrl: 'app/views/directives/general-info.html',
      link: function(scope, elem, attr) {
        console.log(scope, "sdfgsfgss");
        scope.stepNameShow = false;
        scope.stageNoCycleShow = false;
      }
    }
  }
]);
