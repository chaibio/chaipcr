(function() {
  'use strict';

  App.directive('protocolScreenCenterBottomHalf', [
    '$window',
    '$timeout',
    'WindowWrapper',
    '$rootScope',
    function($window, $timeout, WindowWrapper, $rootScope) {
      return {
        restrict: 'AE',
        link: function($scope, elem, attrs) {

          var timeout = null;
          var minWidth = 930;
          var prev = elem.find('[action="previous"]');
          var next = elem.find('[action="next"]');
          var middleGround = elem.find('.middle-ground');
          var generalInfo = elem.find('.general-info-container');
          var bottomGatherData = elem.find('.bottom-gather-data');
          var bottomGatherDataWidth = 243;
          var summaryMode = elem.find('.summary-mode');
          var dataBoxesContainer = elem.find('.data-boxes-container');
          var dataBoxesSummary = elem.find('.data-box-container-summary');
          var dataBoxesSummaryScroll = elem.find('.data-box-container-summary-scroll');
          var bottomCommonItem = elem.find('.bottom-common-item, .name-board');
          var dataBoxes = dataBoxesSummaryScroll.find('.data-boxes');
          var dataBoxesEdit = elem.find('.data-boxes.edit-stage-step');
          var lolPopUp = elem.find('.lol-pop');

          $scope.adjust = function() {
            var padding = 50;
            var numVisibleDataBoxes = 3;
            var prevWidth = prev.width();
            var nextWidth = next.width();
            var mainWidth = $('.inner-container').width() > minWidth ? $('.inner-container').width() : minWidth;
            var middleGroundWidth = mainWidth - (prevWidth + nextWidth);

            elem.css({ width: mainWidth });

            middleGround.css({ width: middleGroundWidth });
            generalInfo.css({ width: middleGroundWidth });
            bottomGatherData.css({ left: (middleGroundWidth - bottomGatherDataWidth - 4) });
            summaryMode.css({ left: middleGroundWidth, width: middleGroundWidth });
            dataBoxesContainer.css({ width: middleGroundWidth });

            var numPadding = numVisibleDataBoxes - 1;
            var eachBoxesWidth = (middleGroundWidth - (padding * numPadding)) / numVisibleDataBoxes;

            dataBoxesSummary.css({ width: (eachBoxesWidth * (numVisibleDataBoxes - 1) + padding) });
            for (var i = 0; i < dataBoxes.length; i++) {
              var box = dataBoxes[i];
              var left = i * (eachBoxesWidth + padding);
              $window.$(box).css({
                width: eachBoxesWidth,
                left: left
              });
            }

            bottomCommonItem.width(eachBoxesWidth);
            dataBoxesEdit.css({
              left: (eachBoxesWidth + padding) * 2,
              width: eachBoxesWidth
            });
            // resize big buttons
            dataBoxesEdit.find('button.big_button, button.big_button_disabled').css({ width: eachBoxesWidth });
            // resize small buttons
            var small_button_space = 18;
            var small_button_border_size = 1;
            var eachSmallButtonWidth = ((eachBoxesWidth - small_button_space) / 2) - (small_button_border_size * 2);
            dataBoxesEdit.find('button.small_button, button.small_button_disabled').css({ width: eachSmallButtonWidth });
            lolPopUp.css({ left: ((eachBoxesWidth + padding) * (numVisibleDataBoxes - 1) + ((eachBoxesWidth - lolPopUp.width()) * 0.5)) });
          };

          timeout = $timeout(function() {
            $scope.adjust();
            timeout = null;
          }, 100);

          $scope.$on('window:resize', function() {
            if (timeout) {
              $timeout.cancel(timeout);
              timeout = null;
            }
            timeout = $timeout(function() {
              $scope.adjust();
              timeout = null;
            }, 100);
          });

          $rootScope.$on('sidemenu:toggle', function(){
            if (timeout) {
              $timeout.cancel(timeout);
              timeout = null;
            }
            timeout = $timeout(function() {
              $scope.adjust();
              timeout = null;
            }, 300);
          });
        }
      };
    }
  ]);

})();
