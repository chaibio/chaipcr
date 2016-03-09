window.ChaiBioTech.ngApp.directive('editExpName', [

  function() {

      return {
        restric: "E",
        bindToController: true,

        templateUrl: "app/views/experiment/experiment-properties-name.html",
        controller: 'EditExperimentPropertiesCtrl',

        link: function($scope, elem) {

        }
      };
  }
]);
