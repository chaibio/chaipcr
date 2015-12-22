window.ChaiBioTech.ngApp.directive('allowAdminToggle', [
  function() {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/gather-data-toggle.html',

      scope: {
        data: '=data'
      },

      link: function(scope, elem, attr) {
        scope.show = true;

        scope.$watch("data", function(val, oldVal) {
          scope.configureSwitch(val);
        });

        $(elem).click(function(evt) {

          scope.configureSwitch(!scope.data);
          scope.sendData();
        });

        scope.configureSwitch = function(val) {

          if(val === "admin") {
            $(scope.dragElem).parent().css("background-color", "#8dc63f");
            $(scope.dragElem).children().css("background-color", "#8dc63f");
            $(scope.dragElem).animate({
              left: "11"
            }, 100);
          } else {
            $(scope.dragElem).parent().css("background-color", "#bbbbbb");
            $(scope.dragElem).children().css("background-color", "#bbbbbb");
            $(scope.dragElem).animate({
              left: "1"
            }, 100);
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

          if(scope.data === "admin") {
            scope.data = "default";
          } else {
            scope.data = "admin";
          }
          //scope.data = !scope.data;
          //scope.$parent['update']();
        };

        scope.dragElem = $(elem).find(".outer-circle").draggable({
          containment: "parent",
          axis: "x",

          stop: function() {
            var pos = $(this).position().left;
            scope.processMovement(pos, false);
          }
        });
      }
    };
  }
]);
