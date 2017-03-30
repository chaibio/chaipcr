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
            var numPadding = 2;
            var mainWidth = elem.width();
            var prevWidth = elem.find('[action="previous"]').width();
            var nextWidth = elem.find('[action="next"]').width();
            var middleGroundWidth = mainWidth - (prevWidth + nextWidth);

            elem.find('.middle-ground').width(middleGroundWidth + 'px');

            var dataBoxesContainer = elem.find('.data-boxes-container');

            var dataBoxesSummary = elem.find('.data-box-container-summary');
            var dataBoxesTempChange = elem.find('.data-boxes.temperature-change');
            var dataBoxesAutoDelta = elem.find('.data-boxes.auto-delta');

            var dataBoxesEdit = elem.find('.data-boxes.edit-stage-step');

            dataBoxesContainer.width(middleGroundWidth + 'px');

            var eachBoxesWidth = (middleGroundWidth - (50 * numPadding)) / 3;

            dataBoxesSummary.css({width: (eachBoxesWidth * 2 + padding) + 'px'})

            dataBoxesTempChange.width(eachBoxesWidth + 'px');
            elem.find('.bottom-common-item').width(eachBoxesWidth + 'px');

            dataBoxesAutoDelta.width(eachBoxesWidth + 'px');
            dataBoxesEdit.width(eachBoxesWidth + 'px');

            dataBoxesAutoDelta.css({ left: (eachSmallButtonWidth + padding) + 'px' });
            dataBoxesEdit.css({ left: (eachBoxesWidth + padding) * 2 + 'px' });

            // resize big buttons
            dataBoxesEdit.find('button.big_button, button.big_button_disabled').css({ width: eachBoxesWidth + 'px' });
            // resize small buttons
            var small_button_space = 17 + 4
            var eachSmallButtonWidth = (eachBoxesWidth - small_button_space) / 2
            dataBoxesEdit.find('button.small_button, button.small_button_disabled').css({ width: eachSmallButtonWidth + 'px' });

          }

          setTimeout(adjustWidth, 1500);

          $(window).resize(function() {
            console.log('protocol resizing ....');
            adjustWidth();
          })

        }
      };
    }
  ]);

})();
