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
        var identifierClass = 'home-page-active-del-identifier';

        scope.$watch('deleteMode', function(newVal, oldVal) {
          HomePageDelete.activeDelete = newVal;
          if(newVal === false && scope.deleteClicked) {
            scope.reset();
          }
        });

        scope.deleteClickedHandle = function() {

          scope.deleteClicked = !scope.deleteClicked;
          HomePageDelete.deactiveate(scope, elem);

          if(scope.deleteClicked) {
            angular.element(elem).parent()
              .addClass(identifierClass);
            angular.element(HomePageDelete.activeDeleteElem).parent()
              .removeClass(identifierClass);
            HomePageDelete.activeDeleteElem = elem;
          } else {
            angular.element(elem).parent().removeClass(identifierClass);
          }

          HomePageDelete.activeDelete = scope;
        };

        scope.reset = function() {
          angular.element(elem).parent().removeClass(identifierClass);
          scope.deleteClicked = false;
        };

        scope.tryDeletion = function() {
          scope.deleteExp(scope.experiment);
        };

      }
    };
  }
]);
