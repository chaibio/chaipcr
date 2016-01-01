window.ChaiBioTech.ngApp.directive('returnHome', [
  '$window',
  function(window) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/settings/return-home.html',
      link: function(scope, elem, attr) {

        scope.position = function() {
          if(window.innerHeight < 768 && window.innerHeight > 500) {
            angular.element(elem).css("top", (window.innerHeight - 105) + "px");
          }
        };

        angular.element(window).bind('resize', function(evt) {
          scope.position();
        });
        
        scope.position();
      }
    };
  }
]);
