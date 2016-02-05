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
        'experiment': '=experiment'
      },

      link: function(scope, elem, attr) {

        scope.deleteClicked = false;
        scope.running = false;

        var identifierClass = 'home-page-active-del-identifier';

        scope.$watch('deleteMode', function(newVal, oldVal) {
          HomePageDelete.activeDelete = HomePageDelete.activeDeleteElem = false;
          if(newVal === false && scope.deleteClicked) {
            scope.reset();
          }
        });

        scope.$watch('experiment', function(newVal, oldVal) {
          if(newVal) {
            scope.running = (newVal.started_at || false) && !(newVal.completed_at || false);
            console.log(scope.running, newVal.started_at, newVal.completed_at);
          }
        });

        scope.deleteClickedHandle = function() {
          
          if(!scope.running) {
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
          }
        };

        scope.reset = function() {
          scope.deleteClicked = false;
          angular.element(elem).parent().removeClass(identifierClass);
        };

        scope.tryDeletion = function() {
          scope.deleteExp(scope.experiment);
        };

      }
    };
  }
]);
