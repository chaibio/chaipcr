
// http://stackoverflow.com/questions/14183025/setting-application-wide-http-headers-in-angularjs

(function () {

  var myapp = window.ChaiBioTech.ngApp;

  myapp.factory('httpRequestInterceptor', function () {
    return {
      request: function (config) {

        // use this to destroying other existing headers
        config.headers = config.headers || {};

        config.headers['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');

        // use this to prevent destroying other existing headers
        // config.headers['Authorization'] = 'authentication;

        return config;
      }
    };
  });

  myapp.config([ '$httpProvider', function ($httpProvider) {
    $httpProvider.interceptors.push('httpRequestInterceptor');
  }]);

}).call(this);