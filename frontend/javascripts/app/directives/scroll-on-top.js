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

window.ChaiBioTech.ngApp.directive('scrollOnTop', [
  'scrollService',
  function(scrollService) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/directives/scroll-on-top.html',

      scope: {
        width: "@width",
        left: "@left"
      },

      link: function(scope, elem, attr) {
        scrollService.move = 0;
        scope.element = $(".canvas-containing");
        scope.scrollDiff = 0;
        scope.position = 0;
        var bar = $(elem).find(".foreground-bar");

        scope.$watch("width", function(newVal, oldVal) {

          var ratio = (newVal / 1024);
          var width = 300 / ratio;
          var canvasDiff = newVal - 1024;
          scope.scrollDiff = 300 - width;

          scrollService.move = canvasDiff / scope.scrollDiff;
          // Automatically update
          if(scope.position !== 0) { // make this a new service , so these numbers can be used in events..
            var oldWidth = 300 / (oldVal / 1024);
            var moveLeft = Math.abs(oldWidth - width);
            scope.position = Math.abs(scope.position - moveLeft);
            bar.css("left", scope.position + "px");
            bar.css("width", width + "px");
          }

          bar.css("width", width + "px");
        });

        scope.$watch('left', function(newVal, oldVal) {
          bar.css("left", (newVal / scrollService.move) + "px");
        });

        scope.dragElem = $(elem).find(".foreground-bar").draggable({
          refreshPositions: true,
          containment: "parent",
          axis: "x",

          drag: function(event, ui) {

            if(ui.position.left > 0 && ui.position.left <= scope.scrollDiff) {
              scope.element.scrollLeft(ui.position.left * scrollService.move);
            }

          },

          stop: function(event, ui) {
            scope.position = ui.position.left;
          }
        });
      }
    };
  }
]);
