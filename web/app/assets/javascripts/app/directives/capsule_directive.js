window.ChaiBioTech.ngApp.directive('capsule', [
  'ExperimentLoader',
  '$timeout',
  function(ExperimentLoader, $timeout) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/capsule.html',
      transclude: true,

      scope: {
        data: '=data',
        delta: '@',
        fun: '@func'
      },

      link: function(scope, elem, attr) {

        // data is not readily available as its an inner directive
        scope.$watch("data", function(val) {
          if(angular.isDefined(scope.data)) {
            console.log("okay right place");
            scope.originalValue = Number(scope.data);
              if(scope.delta === "true") {
                scope.configure();
              }
          }
        });

        scope.$watch("delta", function(val) {
          // Remember delta is passed as string.
          if(angular.isDefined(scope.delta)) {
            if(scope.delta === "true") {
              scope.configurePlusMinus("white");
              scope.configure();
            } else if(scope.delta === "false") {
              scope.disable();
            }
          }
        });

        scope.disable = function() {

          scope.configurePlusMinus("grey");
          $(scope.drag).css("left", "0px");
          $(scope.drag).parent().parent().css("background-color", "rgb(205, 205, 205)");
        };

        scope.configurePlusMinus = function(color) {

          $(scope.drag).parent().find(".plus").css("color", color);
          $(scope.drag).parent().find(".minus").css("color", color);
        };

        scope.configure = function() {

          if(scope.originalValue > 0) {
            $(scope.drag).css("left", "36px");
            $(scope.drag).parent().parent().css("background-color", "rgb(238, 49, 24)");
          } else if(scope.originalValue <= 0) {
            $(scope.drag).css("left", "0px");
            $(scope.drag).parent().parent().css("background-color", "rgb(0, 174, 239)");
          }
        };

        // Enabling the drag
        scope.drag = $(elem).find(".ball-cover").draggable({
          containment: "parent",
          axis: "x",

          create: function() {

          },

          stop: function() {

            if(scope.delta === "true") {
              var pos = $(this).position().left;
              if(pos < 18) {
                $(this).css("left", "0px");
                $(this).parent().parent().css("background-color", "rgb(0, 174, 239)");
                scope.originalValue = scope.originalValue * -1;

              } else {
                $(this).css("left", "36px");
                $(this).parent().parent().css("background-color", "rgb(238, 49, 24)");
                scope.originalValue = Math.abs(scope.originalValue);
              }

              scope.$apply(function() {
                scope.data = String(scope.originalValue);
              });

              ExperimentLoader[scope.fun](scope.$parent.$parent.$parent).then(function(data) {
                console.log("updated", data.step);
              });

            } else {
              $(this).css("left", "0px");
            }

          },

        });

      }
    };
  }
]);
