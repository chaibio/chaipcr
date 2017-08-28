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

window.ChaiBioTech.ngApp.directive('allowAdminToggle', [
  function() {
    return {
      restric: 'EA',
      replace: false,
      templateUrl: 'app/views/directives/gather-data-toggle.html',

      scope: {
        data: '=data'
      },

      link: function(scope, elem, attr) {
        scope.show = true;

        scope.$watch("data", function(val, oldVal) {
          scope.configureSwitch(val);
        });

        scope.clickHandler = function() {
          scope.sendData();
        };

        scope.configureSwitch = function(val) {

          if(val === "admin") {
            angular.element(scope.dragElem).parent().css("background-color", "#8dc63f");
            angular.element(scope.dragElem).children().css("background-color", "#8dc63f");
            angular.element(scope.dragElem).animate({
              left: "11"
            }, 50);
          } else {
            angular.element(scope.dragElem).parent().css("background-color", "#bbbbbb");
            angular.element(scope.dragElem).children().css("background-color", "#bbbbbb");
            angular.element(scope.dragElem).animate({
              left: "1"
            }, 50);
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

          if(scope.data === "admin") {
            scope.data = "default";
          } else {
            scope.data = "admin";
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
