window.ChaiBioTech.ngApp.directive('numbersOnly', [
  function(){
     return {

       require: 'ngModel',
       restrict: 'A',

       link: function(scope, element, attrs, modelCtrl) {

         modelCtrl.$parsers.push(function (inputValue) {

             if (inputValue === undefined) { return ''; }
             var transformedInput = inputValue.replace(/[^0-9]/g, '');
             // condition to limit transformed value below 1 million
             transformedInput = (String(transformedInput).length >= 7) ? transformedInput.substr(0, 6) : transformedInput;
             if (transformedInput !== inputValue) {
                modelCtrl.$setViewValue(transformedInput);
                modelCtrl.$render();
             }

             return transformedInput;
         });
       }
     };
  }
]);
