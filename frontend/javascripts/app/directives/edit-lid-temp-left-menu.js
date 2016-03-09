window.ChaiBioTech.ngApp.directive("editLidTemp", [

  function() {
    return {
      restric: 'E',
      bindToController: true,

      templateUrl: "app/views/experiment/experiment-properties-suboption.html",
      controller: 'EditExperimentPropertiesCtrl',

      link: function($scope, elem) {

      }
    };
  }
]);
