window.ChaiBioTech.ngApp.directive("editLidTemp", [

  function() {
    return {
      restric: 'E',
      bindToController: true,

      templateUrl: "app/views/experiment/experiment-properties-lid-temp.html",
      controller: 'EditExperimentPropertiesCtrl',

      link: function($scope, elem) {

      }
    };
  }
]);
