window.ChaiBioTech.ngApp.directive('numbersOnly', [
  function(){
     return {

       require: 'ngModel',
       restrict: 'A',

       link: function(scope, element, attrs, modelCtrl) {

         modelCtrl.$parsers.push(function (inputValue) {

             if (inputValue === undefined) return '';
             var transformedInput = inputValue.replace(/[^0-9]/g, '');
             if (transformedInput != inputValue) {
                modelCtrl.$setViewValue(transformedInput);
                modelCtrl.$render();
             }

             return transformedInput;
         });
       }
     };
  }
]);
