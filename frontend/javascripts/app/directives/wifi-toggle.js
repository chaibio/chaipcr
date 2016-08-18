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
        scope.inProgress = false;

        scope.$watch("data", function(val, oldVal) {
          console.log("data change here");
          scope.configureSwitch(val);
        });

        scope.$watch('noDevice', function(val, oldVal) {
          if(val) {
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
          console.log("pro");
          scope.sendData();
        };

        scope.configureSwitch = function(val) {

          if(scope.noDevice === false /*&& scope.inProgress === false*/) {
            if(val) {
              angular.element(scope.dragElem).parent().css("background-color", "#8dc63f");
              angular.element(scope.dragElem).children().css("background-color", "#8dc63f");
              angular.element(scope.dragElem).animate({
                left: "11"
              }, 50);
              scope.inProgress = true;
            } else if(val === false) {
              angular.element(scope.dragElem).parent().css("background-color", "#bbbbbb");
              angular.element(scope.dragElem).children().css("background-color", "#bbbbbb");
              angular.element(scope.dragElem).animate({
                left: "1"
              }, 50);
              scope.inProgress = true;
            }
          }
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
          //console.log(scope.noDevice, scope.inProgress);
          if(scope.noDevice === false) {
            if(scope.data) {
              scope.data = !scope.data;
            } else {
              scope.data = true;
            }
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
