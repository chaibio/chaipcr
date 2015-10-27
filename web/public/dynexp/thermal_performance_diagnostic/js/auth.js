
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