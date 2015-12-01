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
        scope.$watch("data", function(val, oldVal) {
          if(angular.isDefined(scope.data)) {
            console.log("okay right place", scope.data);
            scope.originalValue = Number(scope.data);
              if(scope.delta === "true") {
                scope.configure(oldVal);
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

        $(elem).click(function(evt) {

          if(($(evt.target).is(".minus") || $(evt.target).is(".plus")) && scope.delta === "true") {
            
            scope.originalValue = scope.originalValue * -1;
            scope.configure();
            scope.sendValue();
          }
        });

        scope.disable = function() {

          scope.configurePlusMinus("rgb(205, 205, 205)");
          $(scope.drag).css("left", "0px");
          $(scope.drag).parent().parent().css("background-color", "rgb(205, 205, 205)");
          $(scope.drag).parent().parent().css("border-color", "rgb(205, 205, 205)");
          $(scope.drag).find(".center-circle").css("background-color", "rgb(205, 205, 205)");
        };

        scope.configurePlusMinus = function(color) {

          $(scope.drag).parent().find(".plus").css("color", color);
          $(scope.drag).parent().find(".minus").css("color", color);
        };

        scope.configure = function(oldVal) {

          if(scope.originalValue > 0) {
            $(scope.drag).css("left", "16px");
            $(scope.drag).parent().parent().css("background-color", "rgb(238, 49, 24)");
            $(scope.drag).parent().parent().css("border-color", "rgb(238, 49, 24)");
            $(scope.drag).find(".center-circle").css("background-color", "rgb(238, 49, 24)");

          } else if(scope.originalValue < 0) {
            $(scope.drag).css("left", "0px");
            $(scope.drag).parent().parent().css("background-color", "#000");
            $(scope.drag).parent().parent().css("border-color", "#000");
            $(scope.drag).find(".center-circle").css("background-color", "#000");
          } else {
            $(scope.drag).css("left", "0px");
            $(scope.drag).parent().parent().css("background-color", "#000");
            $(scope.drag).parent().parent().css("border-color", "#000");
            $(scope.drag).find(".center-circle").css("background-color", "#000");
          }
        };

        scope.sendValue = function() {

          scope.$apply(function() {
            scope.data = String(scope.originalValue);
          });
          ExperimentLoader[scope.fun](scope.$parent.$parent.$parent).then(function(data) {
            console.log("updated", data.step);
          });
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
              if(pos < 7) {
                $(this).css("left", "0px");
                $(this).parent().parent().css("background-color", "#000");
                $(this).parent().parent().css("border-color", "#000");
                $(this).find(".center-circle").css("background-color", "#000");
                scope.originalValue = scope.originalValue * -1;

              } else {
                $(this).css("left", "16px");
                $(this).parent().parent().css("background-color", "rgb(238, 49, 24)");
                $(this).parent().parent().css("border-color", "rgb(238, 49, 24)");
                $(this).find(".center-circle").css("background-color", "rgb(238, 49, 24)");
                scope.originalValue = Math.abs(scope.originalValue);
              }
              if(scope.originalValue !== 0) {
                scope.sendValue();
              }

            } else {
              $(this).css("left", "0px");
            }

          },

        });

      }
    };
  }
]);
