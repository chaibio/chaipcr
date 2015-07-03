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
        data: '=data'
      },

      link: function(scope, elem, attr) {

        // data is not readily available as its an inner directive
        scope.$watch("data", function(val) {
          if(angular.isDefined(scope.data)) {
            scope.originalValue = Number(scope.data);
          }
        });
        // Enabling the drag
        scope.drag = $(elem).find(".ball-cover").draggable({
          containment: "parent",
          axis: "x",

          create: function() {

          },

          stop: function() {

            var pos = $(this).position().left;
            if(pos < 18) {
              $(this).css("left", "0px");
              //that.options.parent.trigger("signChanged", -1);
            } else {
              $(this).css("left", "36px");
              //that.options.parent.trigger("signChanged", 1)
            }
          },

        });

      }
    };
  }
]);
