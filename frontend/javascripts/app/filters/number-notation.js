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

window.ChaiBioTech.ngApp.filter('numberNotation', [
  function() {
    return function(value) {

      if(isNaN(value)) {
        return "";
      }

      stn = Number(value);
      var data = stn.toExponential().toString().split(/[eE]/);
      var m1 = Number(data[0]);
      var b1 = Number(data[1]);

      var data1 = stn.toString().split(/[eE]/);
      var int1, float1;
      var pow = Number(data1[1]);
      var index = 0, i;
      if( pow < 0){
        int1 = 0;
        float1 = "0".repeat(Math.abs(pow) - 1) + m1.toString().replace('.', '');

        float1 = float1.substring(0, 12);
        index = 0;
        for (i = float1.length - 1; i >= 0; i--) {
          if(float1[i] == '0'){
            index++;
          } else {
            break;
          }
        }

        float1 = float1.substring(0, float1.length - index);
      } else {
        int1 = stn.toString().split('.')[0];
        float1 = stn.toString().split('.')[1];

        if(float1){
          float1 = float1.substring(0, 12);
          index = 0;
          for (i = float1.length - 1; i >= 0; i--) {
            if(float1[i] == '0'){
              index++;
            } else {
              break;
            }
          }     
          
          float1 = float1.substring(0, float1.length - index);             
        }
      }

      if(b1 < 12 && b1 > -12){
        if(float1){
          return Number(int1).toLocaleString('en') + '.' + float1.substring(0, 12);
        } else {
          return Number(int1).toLocaleString('en');
        }
      } else {
        return m1.toString()+"E"+b1.toString();
      }
    };
  }
]);
