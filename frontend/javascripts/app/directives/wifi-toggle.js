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
        data: '=wirelessStatus',
        noDevice: '=noWifiAdapter'
      },

      link: function(scope, elem, attr) {
        scope.show = true;
        // Keep track if a on/off wifi is in progress. We need this so that, It blocks another change
        // while one change is already in progress;
        scope.inProgress = false;

        scope.$watch("data", function(val, oldVal) {
          //scope.configureSwitch(val);
          // here we need some re-work , we need dont have to look for inprogress for the very first time.
          // but after that we need to look for inProgress.
          // may be remove this watch right after we configure the switch 
        });

        scope.$watch('noDevice', function(device, oldVal) {
          if(device) {
            scope.dragElem.draggable('disable');
          }
        });

        scope.$on('wifi_restarted', function() {
          scope.inProgress = false;
        });

        scope.$on('wifi_stopped', function() {
          scope.inProgress = false;
        });

        scope.clickHandler = function() {
          scope.sendData();
        };

        scope.configureSwitch = function(switchState) {

          if(scope.noDevice === false /*&& scope.inProgress === false*/) {
            if(switchState === true && scope.inProgress === false) {
              scope.changeState("#8dc63f", "11");
              scope.inProgress = true;
            } else if(switchState === false && scope.inProgress === false) {
              scope.changeState("#bbbbbb", "1");
              scope.inProgress = true;
            }
            return;
          }
          scope.changeState("#bbbbbb", "1");
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
          if(val !== scope.data) {
            scope.sendData();
          }
        };

        scope.sendData = function() {
          console.log(scope.inProgress);
          if(scope.noDevice === false && scope.inProgress === false) {
            if(scope.data) {
              scope.data = !scope.data;
            } else {
              scope.data = true;
            }
            scope.configureSwitch(scope.data);
          }
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
