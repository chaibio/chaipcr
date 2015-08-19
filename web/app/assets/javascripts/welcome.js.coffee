#= require jquery
#= require angular
#= require_self

App = angular.module 'WelcomeApp', []

App.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.headers.post['X-CSRF-Token'] = angular.element('meta[name="csrf-token"]').attr 'content'
  $httpProvider.defaults.headers.post['X-Requested-With'] = 'XMLHttpRequest'
]

App.controller 'WelcomeCtrl', [
  '$scope'
  '$http'
  '$window'
  ($scope, $http, $window) ->
    $scope.user =
      name: 'Admin'
      role: 'admin'

    $scope.submit = (data) ->
      promise = $http.post '/users', user: data
      promise.then (resp) ->
        $window.location.assign '/'
      promise.catch (resp) ->
        $scope.errors = resp.data.user.errors

]