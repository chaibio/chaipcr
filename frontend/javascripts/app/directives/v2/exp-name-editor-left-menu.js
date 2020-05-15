window.ChaiBioTech.ngApp.directive('expNameEditor', [

  function() {

      return {
        restric: "E",
        bindToController: true,
        scope: {
          status: "="
        },
        templateUrl: "app/views/directives/v2/exp-name-editor-left-menu.html",
        controller: 'ExpNameEditorCtrl',

        link: function($scope, elem) {
          //console.log("wow cool", $scope);
        }
      };
  }
]);
