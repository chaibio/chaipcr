window.ChaiBioTech.ngApp.directive('arrow', [
  'ExperimentLoader',
  function(ExperimentLoader) {

    return {
      restric: 'EA',
      replace: true,
      scope: false,
      templateUrl: 'app/views/directives/arrow.html',
      link: function(scope, elem) {
        console.log($(elem).attr('action'));

        /*$(elem).click(function() {
          scope.stage = ExperimentLoader.getNew();
          //console.log()

          console.log(scope);
          //scope.stage.name = "Jossie"
          scope.$apply();
        });*/
      }
    }
  }
]);
