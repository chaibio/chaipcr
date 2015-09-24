
App = angular.module 'LoginApp', []

App.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.headers.post['X-CSRF-Token'] = angular.element('meta[name="csrf-token"]').attr 'content'
  $httpProvider.defaults.headers.post['X-Requested-With'] = 'XMLHttpRequest'
]

App.controller 'LoginCtrl', [
  '$scope'
  '$http'
  '$window'
  ($scope, $http, $window) ->

    angular.element('body').addClass('login-state-active')
    $scope.$on 'destroy', ->
      angular.element('body').removeClass('login-state-active')

    $scope.user =
      role: 'admin'

    $scope.login = (data) ->
      promise = $http.post '/login', data
      promise.then (resp) ->
        $.jStorage.set 'authToken', resp.data.authentication_token
        $.jStorage.set 'userId', resp.data.user_id
        $window.location.assign '/'
      promise.catch (resp) ->
        $scope.errors = resp.data.errors

]
