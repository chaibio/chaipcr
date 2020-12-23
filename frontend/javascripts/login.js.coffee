
App = angular.module 'LoginApp', []

App.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.defaults.headers.post['X-CSRF-Token'] = angular.element('meta[name="csrf-token"]').attr 'content'
  $httpProvider.defaults.headers.post['X-Requested-With'] = 'XMLHttpRequest'
]

App.controller 'LoginCtrl', [
  '$scope'
  '$http'
  '$window'
  '$rootScope'
  ($scope, $http, $window, $rootScope) ->

    $rootScope.pageTitle = "Open qPCR | Chai"
    #$scope.software_version = "1.0"

    angular.element('body').addClass('login-state-active')
    $scope.$on 'destroy', ->
      angular.element('body').removeClass('login-state-active')

    @getSoftwareData = () ->
      host = "http://#{window.location.hostname}"
      $http.get('/device').then((device) ->
          if device.data?.serial_number?
            $scope.serial_number = device.data.serial_number

          if device.data?.software?.version?
            $scope.software_version = device.data.software.version
        )

    @getSoftwareData()

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
