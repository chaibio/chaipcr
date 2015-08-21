app = window.ChaiBioTech.ngApp

app.factory 'Auth', [
  '$http'
  ($http) ->

    logout: ->
      $http.post('/logout').then ->
        $.jStorage.deleteKey 'authToken'

]

app.factory 'AuthToken', [
  ->
    request: (config) ->
      access_token = $.jStorage.get('authToken', null)
      if access_token and config.url.indexOf('8000') >= 0
        config.url = "#{config.url}#{ if config.url.indexOf('&') < 0 then '?' else '&' }access_token=#{access_token}"
        config.headers['Content-Type'] = 'text/plain'

      config

]

app.config [
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.interceptors.push('AuthToken')
]
