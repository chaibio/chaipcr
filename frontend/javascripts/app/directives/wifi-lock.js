angular.module('ChaiBioTech').directive('wifiLock', [
  function() {
    return {
      templateUrl: 'app/views/directives/wifi-lock.html',
      restric: 'A',
      //replace: true,

      link: function(scope, element, attr) {
        //console.log("voila");
      }
    };
  }
]);
