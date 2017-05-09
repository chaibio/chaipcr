(function() {
  'use strict';

  App.service('WindowWrapper', [
    '$window',
    'IsMobile',
    function windowCommon($window, IsMobile) {

      // this serves as indicator which event handlers are already attached by which component to prevent duplicate callbacks
      this.events = {};

      this.width = function() {
        if (IsMobile()) {
          return $window.innerWidth;
        } else {
          return $($window).width();
        }
      };

      this.height = function() {
        return angular.element($window).height();
      };

      this.documentHeight = function() {
        // http://stackoverflow.com/questions/1145850/how-to-get-height-of-entire-document-with-javascript
        var body = $window.document.body,
          html = $window.document.documentElement;

        var height = Math.max(body.scrollHeight, body.offsetHeight,
          html.clientHeight, html.scrollHeight, html.offsetHeight);

        return height;
      };

    }
  ]);

}).call(window);
