 window.ChaiBioTech.ngApp.directive('modalInputField', [
   function() {
     return {
        restrict: 'E',
        templateUrl: 'app/views/directives/v2/modal-input-field.html',
        replace: true,
        transclude: true,
        scope: {
          cssClass: '@class',
          error: '=',
          caption: '@',
          field: '@',
          label: '@',
          type: '@',
          isShow: '=',
        },
        link: function(scope,element,attrs,ctrl, transclude){
          element.find('p').replaceWith(transclude());
          scope.changeShow = function() {
            scope.isShow = !scope.isShow;
            scope.$apply();
          };
        }
     };
   }
 ]);
