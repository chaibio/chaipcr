window.ChaiBioTech.ngApp.directive('leftMenu', [

  function() {
    return {

      restric: "E",
      bindToController: true,
      replace: true,

      templateUrl: "app/views/experiment/left-menu.html",
      controller: 'ExperimentMenuOverlayCtrl',

      link: function($scope, elem) {
        
      }
    };
  }
]);
