(function() {
  'use strict';

  App.service('WindowWrapper', [
    '$window',
    'IsMobile',
    function windowCommon($window, IsMobile) {

      // this serves as indicator which event handlers are already attached by which component to prevent duplicate callbacks
      this.events = {};

      this.width = function () {
        if (IsMobile()) {
          return $window.innerWidth;
        } else {
          return $($window).width();
        }
      };
    }
  ]);

}).call(window);
