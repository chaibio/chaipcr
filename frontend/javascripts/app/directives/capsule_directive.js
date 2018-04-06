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

window.ChaiBioTech.ngApp.directive('capsule', [
  'ExperimentLoader',
  '$timeout',
  function(ExperimentLoader, $timeout) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/capsule.html',
      transclude: true,

      scope: {
        data: '=data',
        delta: '@',
        fun: '@func'
      },

      link: function(scope, elem, attr) {
        
        // data is not readily available as its an inner directive
        scope.$watch("data", function(val, oldVal) {
          if(angular.isDefined(scope.data)) {
            scope.originalValue = Number(scope.data);
              if(scope.delta === "true") {
                scope.configure(oldVal);
              }
          }
        });

        scope.$watch("delta", function(val) {
          // Remember delta is passed as string.
          if(angular.isDefined(scope.delta)) {
            if(scope.delta === "true") {
              scope.configurePlusMinus("white");
              scope.configure();
            } else if(scope.delta === "false") {
              scope.disable();
            }
          }
        });

        $(elem).click(function(evt) {
          scope.clickCallback();
        });

        scope.clickCallback = function() {
          
          if(scope.delta === "true") {

            scope.originalValue = scope.originalValue * -1;
            if(scope.originalValue === 0) {
              scope.justInverse();
              return true;
            }
            scope.configure();
            scope.sendValue();
          }
        };

        scope.justInverse = function() {

            var place = $(scope.drag).position().left;

            if(place === 0) {
              scope.positive();
              return true;
            }
            scope.negative();
        };

        scope.positive = function() {

          $(scope.drag).animate({
            left: "16"
          }, 100);
          $(scope.drag).parent().parent().css("background-color", "rgb(238, 49, 24)");
          $(scope.drag).parent().parent().css("border-color", "rgb(238, 49, 24)");
          $(scope.drag).find(".center-circle").css("background-color", "rgb(238, 49, 24)");
        };

        scope.negative = function() {

          $(scope.drag).animate({
            left: "0"
          }, 100);
          $(scope.drag).parent().parent().css("background-color", "#000");
          $(scope.drag).parent().parent().css("border-color", "#000");
          $(scope.drag).find(".center-circle").css("background-color", "#000");
        };

        scope.disable = function() {

          scope.configurePlusMinus("rgb(205, 205, 205)");
          $(scope.drag).css("left", "0px");
          $(scope.drag).parent().parent().css("background-color", "rgb(205, 205, 205)");
          $(scope.drag).parent().parent().css("border-color", "rgb(205, 205, 205)");
          $(scope.drag).find(".center-circle").css("background-color", "rgb(205, 205, 205)");
        };

        scope.configurePlusMinus = function(color) {

          $(scope.drag).parent().find(".plus").css("color", color);
          $(scope.drag).parent().find(".minus").css("color", color);
        };

        scope.configure = function(oldVal) {

          if(scope.originalValue > 0) {
            scope.positive();

          } else if(scope.originalValue <= 0) {
            scope.negative();
          }
        };

        scope.sendValue = function() {

          scope.$apply(function() {
            scope.data = String(scope.originalValue);
          });
          ExperimentLoader[scope.fun](scope.$parent.$parent.$parent).then(function(data) {
            console.log("updated", data.step);
          });
        };
        // Enabling the drag
        scope.drag = $(elem).find(".ball-cover").draggable({
          containment: "parent",
          axis: "x",

          create: function() {

          },

          stop: function() {

            if(scope.delta === "true") {
              var pos = $(this).position().left;
              if(pos < 7) {
                scope.negative();
                scope.originalValue = scope.originalValue * -1;

              } else {
                scope.positive();
                scope.originalValue = Math.abs(scope.originalValue);
              }
              if(scope.originalValue !== 0) {
                scope.sendValue();
              }

            } else {
              $(this).css("left", "0px");
            }

          },

        });

      }
    };
  }
]);
