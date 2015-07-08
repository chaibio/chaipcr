
# http://stackoverflow.com/questions/14183025/setting-application-wide-http-headers-in-angularjs

app = window.ChaiBioTech.ngApp

app.service 'CSRFToken', [
  '$window'
  ($window) ->
    request: (config) ->
      config.headers = config.headers || {}
      config.headers['X-CSRF-Token'] = $window.$('meta[name=csrf-token]').attr('content')
      config.headers['X-Requested-With'] = 'XMLHttpRequest'
      config

]

app.config [
  '$httpProvider'
  ($httpProvider) ->
    $httpProvider.interceptors.push('CSRFToken')
]
