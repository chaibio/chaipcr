window.App.directive('expNameEditor', [

  function() {

      return {
        restric: "E",
        bindToController: true,
        scope: {
          status: "="
        },
        templateUrl: "dynexp/pika_test/views/v2/directives/exp-name-editor-left-menu.html",
        controller: 'ExpNameEditorCtrl',

        link: function($scope, elem) {
          //console.log("wow cool", $scope);
        }
      };
  }
]);
