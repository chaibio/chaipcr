angular.module('ChaiBioTech').directive('wifiLock', [
  '$rootScope',
  function($rootScope) {
    return {
      templateUrl: 'app/views/directives/wifi-lock.html',
      restric: 'E',
      //replace: true,
      scope: {
        encryption: "@encryption",
        ssid: "@ssid"
      },

      link: function(scope, element, attr) {
        scope.$on('$stateChangeStart', function(event, toState, toParams) {
          //console.log(toState, toParams);
          if(toParams.name === scope.ssid) {
            //angular.element(element).addClass("selected");
            scope.selected = true;
            console.log("clciked", element);
          } else {
            scope.selected = false;
          }
        });
        //console.log("voila");
        scope.$watch("encryption", function(val) {
          if(scope.encryption === "") {
            console.log("bingo");
            angular.element(element).hide();
          }
        });
        }
    };
  }
]);
