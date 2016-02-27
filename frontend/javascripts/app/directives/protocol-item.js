window.ChaiBioTech.ngApp.directive('protocolItem', [
  function() {
    return {
      restrict: 'EA',
      scope: {
        state: '@state'
      },
      template: '<span>{{message}}</span>',
      link: function(scope, elem) {
        scope.message = "";
        scope.$watch('state', function(data) {
          if(data) {
            if(scope.state === 'NOT_STARTED') {
              scope.message = "EDIT PROTOCOL";
            } else {
              scope.message = "VIEW PROTOCOL";
            }
          }
        });
      }
    };
  }
]);
