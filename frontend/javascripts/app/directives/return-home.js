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

window.ChaiBioTech.ngApp.directive('returnHome', [
  '$window',
  function(window) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/settings/return-home.html',
      link: function(scope, elem, attr) {

        scope.position = function() {
          if(window.innerHeight < 768 && window.innerHeight > 500) {
            angular.element(elem).css("top", (window.innerHeight - 105) + "px");
          }
        };

        angular.element(window).bind('resize', function(evt) {
          scope.position();
        });
        
        scope.position();
      }
    };
  }
]);
