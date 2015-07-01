window.ChaiBioTech.ngApp.factory('stage', [
  'ExperimentLoader',
  '$rootScope',
  function(ExperimentLoader, $rootScope) {

    return function(okay) {
      this.init = function() {
        console.log("Wow", okay, $rootScope);
      }
    }

  }
]);
