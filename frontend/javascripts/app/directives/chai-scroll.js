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

window.ChaiBioTech.ngApp.directive('chaiScroll', [
  function() {
    return {
      restrict: 'A',
      scope: {

      },
      link: function($scope, elem, attr) {
        $scope.expName = attr.chaiScroll;
        if($scope.expName.length > 10) {
          console.log($scope.expName);

          var el = $(elem).find('.home-page-exp-name');
          $scope.createMarquee = function() {
            el.marquee({
              //duplicated: true,
              direction: 'right',
              duration: 2000,
              startVisible: true
            });
            el.marquee('pause');
          }
          //console.log(el);


          angular.element(elem).hover(function(evt) {
            el.marquee('resume');
          }, function(evt) {
            el.marquee('firstPlzce');
            el.marquee('pause');
            //$scope.createMarquee();
          });
          $scope.createMarquee();
        }
      }
    }
  }
]);
