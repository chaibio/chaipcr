
# http://stackoverflow.com/questions/14183025/setting-application-wide-http-headers-in-angularjs

app = window.ChaiBioTech.ngApp

app.service 'CSRFToken', [
  '$window'
  ($window) ->
    request: (config) ->

      if config.url.indexOf('8000') < 0 && config.url.indexOf("update.chaibio.com") < 0
        config.headers['X-CSRF-Token'] = $window.$('meta[name=csrf-token]').attr('content')
        config.headers['X-Requested-With'] = 'XMLHttpRequest'

      config

]

app.config [
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.interceptors.push('CSRFToken')
]
