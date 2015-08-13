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
      if $window.authToken and config.url.indexOf('8000') >= 0
        config.url = "#{config.url}#{ if config.url.indexOf('&') < 0 then '?' else '&' }access_token=#{$window.authToken}"
        config.headers['Content-Type'] = 'text/plain'

      config

]

app.config [
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.interceptors.push('AuthToken')
]
