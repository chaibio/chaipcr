
# http://stackoverflow.com/questions/14183025/setting-application-wide-http-headers-in-angularjs

app = window.ChaiBioTech.ngApp

app.service 'httpRequestInterceptor', [
  '$window'
  ($window) ->
    request: (config) ->
      config.headers = config.headers || {}
      config.headers['X-CSRF-Token'] = $window.$('meta[name=csrf-token]').attr('content')
      config

]

app.config [
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.interceptors.push('httpRequestInterceptor')
]