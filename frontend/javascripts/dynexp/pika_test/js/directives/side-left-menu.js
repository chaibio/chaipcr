window.App.directive('leftSideMenu', [
  '$rootScope',
  function($rootScope) {
    return {

      restric: "E",
      bindToController: true,
      //replace: true,

      templateUrl: 'dynexp/pika_test/views/v2/directives/side-left-menu.html',
      controller: 'ExperimentMenuOverlayCtrl',

      link: function($scope, elem) {

        $scope.confirmStatus = false;
        $scope.isConfirmDelete = false;        

        $scope.$on("runReady:true", function() {
          $scope.confirmStatus = true;
        });

        angular.element(elem).click(function(e) {
          if($scope.confirmStatus === true && e.target.innerHTML !== "Run Experiment") {
            $rootScope.$broadcast("runReady:false");
            $scope.confirmStatus = false;
          }

          if($scope.isConfirmDelete === true && e.target.innerHTML !== "Delete") {
            $scope.isConfirmDelete = false;
          }
        });
      }
    };
  }
]);
