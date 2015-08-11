app = window.ChaiBioTech.ngApp

app.factory 'Auth', [
  '$http'
  '$window'
  ($http, $window) ->

    login: (email, password) ->
      loginPromise = $http.post('/login', {email: email, password: password}, ignoreAuthModule: true)
      loginPromise.then (resp) ->
        $window.authToken = resp.data.authentication_token

      loginPromise

    isLoggedIn: ->
      promise = $http.get('/loggedin', null, ignoreAuthModule: true)
      promise.then (resp) ->
        $window.authToken = resp.data.authentication_token

      promise

    logout: ->
      $http.post('/logout').then ->
        $window.authToken = null

]

app.factory 'AuthToken', [
  '$window'
  ($window) ->
    request: (config) ->
      corsCheck = /8000/
      if $window.authToken and corsCheck.test(config.url)
        config.headers = config.headers || {}
        config.headers.Authorization = "Token #{$window.authToken}"

      console.log config
      config

]

app.config [
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.interceptors.push('AuthToken')
]
