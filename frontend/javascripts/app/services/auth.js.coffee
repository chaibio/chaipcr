###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
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
      if !access_token
        re = new RegExp("authentication_token" + "=([^;]+)")
        value = re.exec(document.cookie)
        access_token = unescape(value[1])
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
