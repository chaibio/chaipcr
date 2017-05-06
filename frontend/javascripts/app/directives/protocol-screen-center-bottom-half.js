(function() {
  'use strict';

  App.directive('protocolScreenCenterBottomHalf', [
    '$window',
    '$timeout',
    function($window, $timeout) {
      return {
        restrict: 'AE',
        link: function($scope, elem, attrs) {

          var timeout = null;
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

          function adjustWidth() {
            console.log('Readjusting protocol screen');
            var padding = 50;
            var numVisibleDataBoxes = 3;
            var mainWidth = $($window).width();
            var prevWidth = elem.find('[action="previous"]').width();
            var nextWidth = elem.find('[action="next"]').width();
            var middleGroundWidth = mainWidth - (prevWidth + nextWidth);

            elem.css({ width: mainWidth });
            middleGround.css({ width: middleGroundWidth + 'px' });
            generalInfo.css({ width: middleGroundWidth + 'px' });
            bottomGatherData.css({ left: (middleGroundWidth - bottomGatherDataWidth - 4) });
            summaryMode.css({ left: middleGroundWidth });
            dataBoxesContainer.width(middleGroundWidth + 'px');

            var numPadding = numVisibleDataBoxes - 1;
            var eachBoxesWidth = (middleGroundWidth - (padding * numPadding)) / numVisibleDataBoxes;

            dataBoxesSummary.css({ width: (eachBoxesWidth * (numVisibleDataBoxes - 1) + padding) + 'px' });
            for (var i = 0; i < dataBoxes.length; i++) {
              var box = dataBoxes[i];
              var left = i * (eachBoxesWidth + padding);
              $window.$(box).css({
                width: eachBoxesWidth + 'px',
                left: left + 'px'
              });
            }

            bottomCommonItem.width(eachBoxesWidth + 'px');
            dataBoxesEdit.width(eachBoxesWidth + 'px');
            dataBoxesEdit.css({ left: (eachBoxesWidth + padding) * 2 + 'px' });
            // resize big buttons
            dataBoxesEdit.find('button.big_button, button.big_button_disabled').css({ width: eachBoxesWidth + 'px' });
            // resize small buttons
            var small_button_space = 18;
            var small_button_border_size = 1;
            var eachSmallButtonWidth = ((eachBoxesWidth - small_button_space) / 2) - (small_button_border_size * 2);
            dataBoxesEdit.find('button.small_button, button.small_button_disabled').css({ width: eachSmallButtonWidth + 'px' });
            lolPopUp.css({ left: ((eachBoxesWidth + padding) * (numVisibleDataBoxes - 1) + ((eachBoxesWidth - lolPopUp.width()) * 0.5)) + 'px' });
          }

          timeout = $timeout(adjustWidth, 100);

          $(window).resize(function() {
            console.log('protocol resizing ....');
            if (timeout) {
              $timeout.cancel(timeout);
            }
            timeout = $timeout(adjustWidth, 100);
          });

        }
      };
    }
  ]);

})();
