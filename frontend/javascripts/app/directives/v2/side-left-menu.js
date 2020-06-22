window.ChaiBioTech.ngApp.directive('leftSideMenu', [
  '$rootScope',
  function($rootScope) {
    return {

      restric: "E",
      bindToController: true,
      //replace: true,

      templateUrl: 'app/views/directives/v2/side-left-menu.html',
      controller: 'ExperimentMenuOverlayCtrl',

      link: function($scope, elem) {
      }
    };
  }
]);
