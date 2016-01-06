/*global angular:true, browser:true */

/**
 * @license HTTP Auth Interceptor Module for AngularJS
 * (c) 2012 Witold Szczerba
 * License: MIT
 */
(function () {

  var responceInterceptor = window.responceInterceptor = angular.module('http-response-interceptor', [
    'ui.router',
    'ngResource',
    'http-auth-interceptor',
    'angularMoment'
  ]);


  responceInterceptor.factory('interceptorFactory', [
    function() {
      return {
        responseError: function(response) {
          console.log(response);
        }
      };
    }
  ]);

  responceInterceptor.config(['$httpProvider',
  function($httpProvider) {
      //$httpProvider.interceptors.push('interceptorFactory');
    }
  ]);
})();
