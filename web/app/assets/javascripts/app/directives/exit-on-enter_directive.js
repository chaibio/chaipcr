window.ChaiBioTech.ngApp.directive('onEnter', [
  '$parse',
  function($parse) {
    return {
      restric: 'A',

      compile: function(elem, attrs) {

        var fn = $parse(attrs['onEnter'], null, true);
        return function ngEventHandler(scope, element) {
          element.on('keyup', function(evt) {

            if(evt.which === 13) {
              var callback = function() {
                fn(scope, {$event:evt});
              };

              scope.$apply(callback);
            }
          });
        }
      }
    }
  }
]);
