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

window.ChaiBioTech.ngApp.service('TimeService', [
  '$rootScope',
  function($rootScope) {

    this.convertToSeconds = function(durationString) {
      console.log(durationString);
      var durationArray = durationString.split(":");

      if(durationArray.length > 1) {
        var tt = [0, 0, 0], len = durationArray.length, HH = 0, MM = 0, SS = 0;

        if(durationArray[len - 1] === "") {
          durationArray[len - 1] = "0";
        }
        if(durationArray[len - 1] && Number(durationArray[len - 1]) <= 60) {
          SS = Number(durationArray[len - 1]);
        } else {
          console.log("Plz verify seconds");
          return false;
        }

        if(durationArray[len - 2] === "") {
            //Probably user input value in the format :60;
            durationArray[len - 2] = "0";
        }

        if(durationArray[len - 2]) {
          MM = Number(durationArray[len - 2]);
        } else {
          console.log("Plz verify Minutes");
          return false;
        }

        if(durationArray[len - 3]) {

          if(Number(durationArray[len - 3]) < 9999) {
            HH = Number(durationArray[len - 3]);
          } else {
            console.log("Plz verify Hours we support upto 9999");
            return false;
          }
        }

        return (HH * 3600) + (MM * 60) + SS;

      } else if(!isNaN(durationString)) {
        return durationString;
      } else {
        $rootScope.$broadcast('alerts.nonDigit');
      }
    };

    this.timeFormating = function(reading) {

      var mins = Number(reading);
      var negative = (mins < 0) ? "-" : "";

      reading = Math.abs(reading);

      var hour = Math.floor(reading / 60);
      hour = (hour < 10) ? "0" + hour : hour;

      var min = reading % 60;
      min = (min < 10) ? "0" + min : min;

      return negative + hour + ":" + min;
    };

    this.newTimeFormatting = function(reading) {

      var negative = (reading < 0) ? "-" : "";
      reading = Math.abs(reading);

      var hour = Math.floor(reading / 3600);
      hour = (hour < 10) ? hour : hour;
			hour = (hour == 0) ? "0" + hour : hour ;

      var noMin = reading % 3600;

      var min = Math.floor(noMin / 60);
      min = (min < 10) ? "0" + min : min;

      var noSec = noMin % 60;
      noSec = (noSec < 10) ? "0" + noSec : noSec;

      if(hour === "00") {
        return negative + min + ":" + noSec;
      }
      return negative + hour + ":" + min + ":" + noSec;
    };

  }
]);
