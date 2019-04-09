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

  /**
   * from this source:
   */
  function getCaretPosition(oField) {
    var iCaretPos = 0;
    if (document.selection) {
      oField.focus();
      var oSel = document.selection.createRange();
      oSel.moveStart('character', -oField.value.length);
      iCaretPos = oSel.text.length;
    } else if (oField.selectionStart || oField.selectionStart == '0')
      iCaretPos = oField.selectionDirection == 'backward' ? oField.selectionStart :
      oField.selectionEnd;
    return (iCaretPos);
  }
  /**
   * from this source
   */
  function setCaretPosition(elem, caretPos) {
    if (elem !== null) {
      if (elem.createTextRange) {
        var range = elem.createTextRange();
        range.move('character', caretPos);
        range.select();
      } else {
        if (elem.selectionStart) {
          elem.focus();
          elem.setSelectionRange(caretPos, caretPos);
        } else
          elem.focus();
      }
    }
  }


window.ChaiBioTech.ngApp.directive('formatNumber', [ '$filter',
  function($filter){
     return {

       require: 'ngModel',
       restrict: 'A',

       link: function(scope, element, attrs, modelCtrl) {
          if (!modelCtrl) {
            return;
          }

          modelCtrl.$formatters.unshift(function () {            
            return (modelCtrl.$modelValue) ? $filter('numberNotation')(modelCtrl.$modelValue) : '';
          });

          modelCtrl.$parsers.unshift(function (viewValue) {

              var cursorPosition = getCaretPosition(element[0]);

              var plainNumber = viewValue.replace(/[\,]/g, '');
              var data = plainNumber.split(/[eE]/);
              var m1 = Number(data[0]);
              var b1 = Number(data[1]);
              var frontDigit ='', backDigit='', powDigit = '';

              if(!isNaN(m1)){
                var data1 = data[0].split('.');                
                if(data1[0].length > 12){
                  var data2 = m1.toExponential().toString().split(/[eE]/);
                  b1 = (isNaN(b1)) ? Number(data2[1]) : Number(data2[1]) + b1;
                  frontDigit = data2[0].substring(0, 12);
                } else {
                  frontDigit = data[0];
                }
              }

              if(!isNaN(b1)){
                if(Math.abs(b1) < 100){
                  powDigit = b1;
                } else {
                  if(b1 >= 100){
                    powDigit = b1.toString().substring(0,2);
                  } else {
                    powDigit = b1.toString().substring(0,3);
                  }
                }
              }

              if(frontDigit.indexOf('.') >= 0){                
                backDigit = frontDigit.substring(frontDigit.indexOf('.'));
                frontDigit = frontDigit.substring(0, frontDigit.indexOf('.'));
              }

              if(viewValue == ''){
                element.val('');
                return '';
              } else if(viewValue == '-') {
                element.val('-');
                return '';
              } else if(viewValue == 'E') {
                element.val('1E');
                return '1E';
              } else if(viewValue == '.') {
                element.val('0.');
                return '0.';
              } else {
                var reg = RegExp(/^([0-9,\+\-])*[.]?([0-9E])*$/);

                if(isNaN(m1)){
                  element.val('');
                  return '';
                } else if(!reg.test(frontDigit + backDigit)){
                  element.val('');
                  return '';
                }
                
                var resultValue = '';                
                var match = [];
                if(powDigit){
                  resultValue = $filter('numberNotation')(frontDigit) + backDigit + 'E' + powDigit;
                  element.val(resultValue);                  
                  if(Math.abs(resultValue.length - viewValue.length) == 1){
                    setCaretPosition(element[0], cursorPosition + resultValue.length - viewValue.length);
                  } else if(Math.abs(resultValue.length - viewValue.length) > 1) {
                    setCaretPosition(element[0], resultValue.length);
                  } else {
                    setCaretPosition(element[0], cursorPosition);
                  }
                  return Number(frontDigit+backDigit + 'E' + powDigit);
                } else {
                  if( ((plainNumber.indexOf('e') > 0) && (plainNumber.indexOf('e') == plainNumber.length - 1)) || 
                      ((plainNumber.indexOf('E') > 0) && (plainNumber.indexOf('E') == plainNumber.length - 1))){

                    resultValue = $filter('numberNotation')(frontDigit) + backDigit + 'E';
                  } else if(
                      ((plainNumber.indexOf('e-') > 0) && (plainNumber.indexOf('e-') == plainNumber.length - 2)) || 
                      ((plainNumber.indexOf('E-') > 0) && (plainNumber.indexOf('E-') == plainNumber.length - 2))
                    ) {

                    resultValue = $filter('numberNotation')(frontDigit) + backDigit + 'E-';
                  } else {
                    if((frontDigit.indexOf('.') == frontDigit.length - 1) && (frontDigit.indexOf('.') > 0)){
                      resultValue = $filter('numberNotation')(frontDigit) + '.';
                    } else {
                      resultValue = $filter('numberNotation')(frontDigit) + backDigit;
                    }
                  }

                  resultValue = (frontDigit.indexOf('-0') == 0) ? '-' + resultValue : resultValue;

                  element.val(resultValue);
                  if(Math.abs(resultValue.length - viewValue.length) == 1){
                    setCaretPosition(element[0], cursorPosition + resultValue.length - viewValue.length);
                  } else if(Math.abs(resultValue.length - viewValue.length) > 1) {
                    setCaretPosition(element[0], resultValue.length);
                  } else {
                    setCaretPosition(element[0], cursorPosition);
                  }
                  return Number(frontDigit+backDigit);
                }
              }
              return '';
          });
       }
     };
  }
]);
