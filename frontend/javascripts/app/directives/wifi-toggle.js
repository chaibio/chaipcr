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

window.ChaiBioTech.ngApp.directive('wifiToggle', [
  'NetworkSettingsService',
  '$rootScope',
  function(NetworkSettingsService, $rootScope) {
    return {
      restric: 'EA',
      replace: false,
      templateUrl: 'app/views/directives/gather-data-toggle.html',

      scope: {
        wirelessStatus: '=wirelessStatus',
        noDevice: '=noWifiAdapter'
      },

      link: function(scope, elem, attr) {

        scope.show = true;
        // Keep track if a on/off wifi is in progress. We need this so that, It blocks another change
        // while one change is already in progress;
        scope.inProgress = false;

        var unregisterWatch = scope.$watch("wirelessStatus", function(stat, oldStat) {
          if(stat) {
            scope.configureSwitch(stat);
            scope.inProgress = false; // We explicitly say it here because we dont have to look for inprogress for the very first time.
            unregisterWatch();
          }
        });

        scope.$watch('inProgress', function(progress) {
          if(progress === true) {
            console.log("inprogress true");
            scope.dragElem.draggable('disable');
          } else if(progress === false) {
            console.log("inprogress false;");
            scope.dragElem.draggable('enable');
          }
        });

        scope.$watch('noDevice', function(deviceNotFound, oldVal) {
          console.log("deviceNotFound", deviceNotFound);
          if(deviceNotFound) {
            scope.changeState("#bbbbbb", "1");
            scope.dragElem.draggable('disable');
          } else {
            scope.dragElem.draggable('enable');
            scope.inProgress = false;
            scope.configureSwitch(scope.wirelessStatus);
            scope.inProgress = false; // Restore the inProgress state, configureSwitch changes it to true.
          }
        });

        scope.$on('wifi_restarted', function() {
          console.log("wifi restarted");
          scope.inProgress = false;
        });

        scope.$on('wifi_stopped', function() {
          console.log("wifi stopped");
          scope.inProgress = false;
          scope.wirelessStatus = false; // Ensure that wirelessStatus is false;
        });

        $rootScope.$on('wifi_adapter_reconnected', function(data, wifiSwitch) {

        });

        scope.clickHandler = function() {

          if(scope.noDevice === false && scope.inProgress === false) {
            console.log("Inside click handler");
            scope.sendData();
          }
        };

        scope.configureSwitch = function(switchState) {
          //if(scope.noDevice === false) {
          console.log("configureSwitch", switchState);
          if(switchState === true) {
            scope.changeState("#8dc63f", "11");
            scope.inProgress = true;
          } else if(switchState === false) {
            scope.changeState("#bbbbbb", "1");
            scope.inProgress = true;
          }
            //return;
          //}
          //scope.changeState("#bbbbbb", "1");
        };

        scope.changeState = function(backgroundColor, left) {

          angular.element(scope.dragElem).parent().css("background-color", backgroundColor);
          angular.element(scope.dragElem).children().css("background-color", backgroundColor);
          angular.element(scope.dragElem).animate({
            left: left
          }, 50);
        };

        scope.processMovement = function(pos, val) {

          if(pos < 6) {
            $(this).css("left", "1px");
          } else {
            $(this).css("left", "11px");
            val = true;
          }
          if(val !== scope.wirelessStatus) {
            scope.sendData();
          }
        };

        scope.sendData = function() {

          scope.wirelessStatus = ! scope.wirelessStatus;
          scope.configureSwitch(scope.wirelessStatus);
        };

        scope.dragElem = angular.element(elem).find(".outer-circle").draggable({
          containment: "parent",
          axis: "x",

          stop: function() {
            var pos = $(this).position().left;
            scope.processMovement(pos, false);
          }
        });
      }
    };
  }
]);
