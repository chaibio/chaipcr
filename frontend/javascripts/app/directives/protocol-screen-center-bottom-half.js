(function() {
  'use strict';

  App.directive('protocolScreenCenterBottomHalf', [
    '$window',
    function($window) {
      return {
        restrict: 'AE',
        link: function($scope, elem, attrs) {

          function adjustWidth() {
            var padding = 50;
            var numVisibleDataBoxes = 3;
            var mainWidth = elem.width();
            var prevWidth = elem.find('[action="previous"]').width();
            var nextWidth = elem.find('[action="next"]').width();
            var middleGroundWidth = mainWidth - (prevWidth + nextWidth);

            elem.find('.middle-ground').width(middleGroundWidth + 'px');

            var dataBoxesContainer = elem.find('.data-boxes-container');
            dataBoxesContainer.width(middleGroundWidth + 'px');

            var dataBoxesSummary = elem.find('.data-box-container-summary');
            var dataBoxesSummaryScroll = elem.find('.data-box-container-summary-scroll');

            var dataBoxes = dataBoxesSummaryScroll.find('.data-boxes');
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

              console.log('left' + i + ': ' + left);
            }

            elem.find('.bottom-common-item, .name-board').width(eachBoxesWidth + 'px');


            var dataBoxesEdit = elem.find('.data-boxes.edit-stage-step');


            dataBoxesEdit.width(eachBoxesWidth + 'px');

            dataBoxesEdit.css({ left: (eachBoxesWidth + padding) * 2 + 'px' });

            // resize big buttons
            dataBoxesEdit.find('button.big_button, button.big_button_disabled').css({ width: eachBoxesWidth + 'px' });
            // resize small buttons
            var small_button_space = 17 + 4;
            var eachSmallButtonWidth = (eachBoxesWidth - small_button_space) / 2;
            dataBoxesEdit.find('button.small_button, button.small_button_disabled').css({ width: eachSmallButtonWidth + 'px' });

            var lolPopUp = elem.find('.lol-pop');
            lolPopUp.css({ left: ((eachBoxesWidth + padding) * (numVisibleDataBoxes - 1) + ((eachBoxesWidth - lolPopUp.width()) * 0.5)) + 'px' });

          }

          setTimeout(adjustWidth, 100);

          $(window).resize(function() {
            console.log('protocol resizing ....');
            adjustWidth();
          });

        }
      };
    }
  ]);

})();
