window.ChaiBioTech.ngApp.directive('deleteMode', [
  'HomePageDelete',
  function(HomePageDelete) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/delete-mode.html',
      scope: {
        'deleteMode': '=mode',
        'deleteExp': '&',
        'experiment': '@experiment'
      },

      link: function(scope, elem, attr) {
        scope.deleteClicked = false;

        scope.$watch('deleteMode', function(newVal, oldVal) {
          if(newVal === false && scope.deleteClicked) {
            scope.reset();
          }
        });

        scope.deleteClickedHandle = function() {

          scope.deleteClicked = !scope.deleteClicked;
          HomePageDelete.deactiveate(scope, elem);

          if(scope.deleteClicked) {
            angular.element(elem).css("left", 212 + "px");
            angular.element('.home-page-active-del-identifier').css("left", 282 + "px")
              .removeClass('home-page-active-del-identifier');
            angular.element(elem).addClass('home-page-active-del-identifier');
          } else {
            angular.element(elem).css("left", 282 + "px")
              .removeClass('home-page-active-del-identifier');
          }

          HomePageDelete.activeDelete = scope;
        };

        scope.reset = function() {
          var left = angular.element(elem).position().left;
          angular.element(elem).css("left", (left + 70) + "px");
          scope.deleteClicked = false;
        };

        scope.tryDeletion = function() {
          console.log(scope.deleteExp(scope.experiment));
        };

      }
    };
  }
]);
