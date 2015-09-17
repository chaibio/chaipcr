
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
        loginPromise = $http.post('/login', {email: data.email, password: data.password})
        loginPromise.then (resp) ->
          $.jStorage.set 'authToken', resp.data.authentication_token
          $.jStorage.set 'userId', resp.data.user_id
          $window.location.assign '/'
      promise.catch (resp) ->
        $scope.errors = resp.data.user.errors

]
