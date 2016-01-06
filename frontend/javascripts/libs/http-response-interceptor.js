/*global angular:true, browser:true */

/**
 * @license HTTP Auth Interceptor Module for AngularJS
 * (c) 2012 Witold Szczerba
 * License: MIT
 */
(function () {

  var responceInterceptor = angular.module('http-response-interceptor', []);



  //console.log($httpProvider);
  responceInterceptor.config(['$httpProvider',
  function($httpProvider) {
      //$httpProvider.Interceptors.push('interceptorFactory');
      //console.log($httpProvider, interceptorFactory);
    }
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

})();
