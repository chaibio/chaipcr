app = window.ChaiBioTech.ngApp

app.factory 'Auth', [
  '$http'
  '$window'
  ($http, $window) ->

    logout: ->
      $http.post('/logout').then ->
        $.jStorage.deleteKey 'authToken'
        # http://stackoverflow.com/questions/2144386/javascript-delete-cookie
        # delete auth cookie
        $window.document.cookie = 'authentication_token=; expires=Thu, 01 Jan 1970 00:00:01 GMT;'

]

app.factory 'AuthToken', [
  ->
    request: (config) ->
      access_token = $.jStorage.get('authToken', null)
      if access_token and config.url.indexOf('8000') >= 0
        config.url = "#{config.url}#{ if config.url.indexOf('&') < 0 then '?' else '&' }access_token=#{access_token}"
        # config.headers['Content-Type'] = 'multipart/form-data'

      config

]

app.config [
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.interceptors.push('AuthToken')
]
