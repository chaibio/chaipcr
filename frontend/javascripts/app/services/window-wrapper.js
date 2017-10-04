(function() {
  'use strict';

  angular.module('ChaiBioTech.Common').service('WindowWrapper', [
    '$window',
    '$rootScope',
    'IsMobile',
    function windowCommon($window, $rootScope, IsMobile) {

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

      angular.element($window).resize(function() {
        $rootScope.$apply(function () {
          $rootScope.$broadcast('window:resize');
        });
      });

      angular.element($window).on('mousedown', function(e) {
        $rootScope.$apply(function () {
          $rootScope.$broadcast('window:mousedown', e);
        });
      });

      angular.element($window).on('mouseup', function(e) {
        $rootScope.$apply(function () {
          $rootScope.$broadcast('window:mouseup', e);
        });
      });

      angular.element($window).on('mousemove', function(e) {
        $rootScope.$apply(function () {
          $rootScope.$broadcast('window:mousemove', e);
        });
      });

    }
  ]);

}).call(window);
