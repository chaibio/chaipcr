#= require jquery
#= require angular
#= require_self

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
    $scope.user =
      role: 'admin'

    $scope.login = (data) ->
      promise = $http.post '/login', data
      promise.then (resp) ->
        $window.location.assign '/'
      promise.catch (resp) ->
        $scope.errors = resp.data.errors

]