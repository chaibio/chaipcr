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
