window.ChaiBioTech.ngApp.directive('modeToggle', [
  function() {
    return {
      restric: 'EA',
      replace: false,
      templateUrl: 'app/views/directives/gather-data-toggle.html',

      scope: {
        data: '=data'
      },

      link: function(scope, elem, attr) {
        scope.show = true;

        scope.$watch("data", function(val, oldVal) {
          if(val) {
            scope.configureSwitch(val);
          }
        });

        scope.clickHandler = function() {
          scope.sendData();
        };

        scope.configureSwitch = function(val) {
          if(val === "auto") {
            angular.element(scope.dragElem).parent().css("background-color", "#8dc63f");
            angular.element(scope.dragElem).children().css("background-color", "#8dc63f");
            angular.element(scope.dragElem).animate({
              left: "11"
            }, 50);
          } else {
            angular.element(scope.dragElem).parent().css("background-color", "#bbbbbb");
            angular.element(scope.dragElem).children().css("background-color", "#bbbbbb");
            angular.element(scope.dragElem).animate({
              left: "1"
            }, 50);
          }

        };

        scope.processMovement = function(pos, val) {

          if(pos < 6) {
            $(this).css("left", "1px");
          } else {
            $(this).css("left", "11px");
            val = true;
          }
          if(val !== scope.data) {
            scope.sendData();
          }
        };

        scope.sendData = function() {

          if(scope.data === "manual") {
            scope.data = "auto";
          } else {
            scope.data = "manual";
          }
          //scope.data = !scope.data;
          //scope.$parent['update']();
        };

        scope.dragElem = angular.element(elem).find(".outer-circle").draggable({
          containment: "parent",
          axis: "x",

          stop: function() {
            var pos = $(this).position().left;
            scope.processMovement(pos, false);
          }
        });

        scope.data = "auto";
        scope.configureSwitch("auto");
      }
    };
  }
]);
