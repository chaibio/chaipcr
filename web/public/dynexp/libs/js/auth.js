(function () {

  var App = angular.module('auth', []);

  App.factory('AuthToken', [
    function() {
      return {
        request: function(config) {
          var access_token;
          access_token = $.jStorage.get('authToken', null);
          if (access_token && config.url.indexOf('8000') >= 0) {
            config.url = "" + config.url + (config.url.indexOf('&') < 0 ? '?' : '&') + "access_token=" + access_token;
            config.headers['Content-Type'] = 'text/plain';
          }
          else {
            config.headers['Authorization'] = access_token;
          }
          return config;
        }
      };
    }
  ]);

  App.config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('AuthToken');
    }
  ]);

  App.service('CSRFToken', [
    '$window', function($window) {
      return {
        request: function(config) {
          if (config.url.indexOf('8000') < 0) {
            config.headers['X-CSRF-Token'] = $window.$('meta[name=csrf-token]').attr('content');
            config.headers['X-Requested-With'] = 'XMLHttpRequest';
          }
          return config;
        }
      };
    }
  ]);

  App.config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('CSRFToken');
    }
  ]);

  App.run([
    '$window', '$rootScope',
    function ($window, $rootScope) {

      $rootScope.$on( 'event:auth-loginRequired', function (e, rejection) {
        $window.document.cookie = 'authentication_token=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
        $.jStorage.deleteKey( 'authToken')
        $window.location.assign( '/');

      });

    }
  ]);

}).call(window);