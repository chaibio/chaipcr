window.ChaiBioTech.ngApp.directive('stageTypePopup', [
  'ExperimentLoader',
  '$timeout',
  'canvas',
  'popupStatus',

  function(ExperimentLoader, $timeout, canvas, popupStatus) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/stage-type-popup.html',

      scope: false,

      link: function(scope, elem, attr) {
        scope.addStage = function(type) {

          if(! scope.infiniteHold) {
            ExperimentLoader.addStage(scope, type)
              .then(function(data) {
                console.log("added", data);
                scope.actionPopup = false;
                scope.fabricStep.parentStage.parent.addNewStage(data, scope.fabricStep.parentStage);
              });
          }
        };
      }
    };
  }
]);
