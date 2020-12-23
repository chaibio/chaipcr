App = angular.module 'WelcomeApp', []

App.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.headers.post['X-CSRF-Token'] = angular.element('meta[name="csrf-token"]').attr 'content'
  $httpProvider.defaults.headers.post['X-Requested-With'] = 'XMLHttpRequest'
]

App.controller 'WelcomeCtrl', [
  '$scope'
  '$http'
  '$window'
  '$rootScope'
  ($scope, $http, $window, $rootScope) ->

    $rootScope.pageTitle = "Open qPCR | Chai"

    $scope.user =
      role: 'admin'

    @getSoftwareData = () ->
      $http.get("/device").then((device) ->
          if device.data?.serial_number?
            $scope.serial_number = device.data.serial_number

          if device.data?.software?.version?
            $scope.software_version = device.data.software.version
        )

    @getSoftwareData()

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
