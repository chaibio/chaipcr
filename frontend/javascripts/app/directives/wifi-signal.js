angular.module('ChaiBioTech').directive('wifiSignal', [
  function() {
    return {
      templateUrl: 'app/views/directives/wifi-signal.html',
      restric: 'E',
      //replace: true,

      link: function(scope, element, attr) {
        //console.log("voila");
      }
    };
  }
]);
