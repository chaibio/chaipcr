/*
 * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

window.ChaiBioTech.ngApp.directive('numbersOnly', [
  function(){
     return {

       require: 'ngModel',
       restrict: 'A',

       link: function(scope, element, attrs, modelCtrl) {

         modelCtrl.$parsers.push(function (inputValue) {

             if (inputValue === undefined) return '';
             var transformedInput = inputValue.replace(/[^0-9]/g, '');
             // condition to limit transformed value below 1 million
             transformedInput = (String(transformedInput).length >= 7) ? transformedInput.substr(0, 6) : transformedInput;
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
