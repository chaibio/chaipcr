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
window.ChaiBioTech.ngApp

.service 'Status', [
  '$http'
  '$q'
  'host'
  '$interval'
  '$timeout'
  '$rootScope'
  ($http, $q, host, $interval, $timeout, $rootScope) ->

    data = null
    isUp = true
    fetchInterval = null
    @listenersCount = 0
    fetching = false
    timeoutPromise = null
    ques = []

    @getData = -> data

    @isUp = -> isUp

    @fetch = ->
      deferred = $q.defer()
      ques.push deferred

      return deferred.promise if fetching
      fetching = true

      timeoutPromise = $timeout =>
        timeoutPromise = null
        fetching = false
      , 10000
      $http.get("#{host}\:8000/status")
      .success (resp) =>
        isUp = true
        oldData = angular.copy data
        data = resp
        for def in ques by 1
          def.resolve data
        $rootScope.$broadcast 'status:data:updated', data, oldData

      .error (resp) ->
        isUp = if resp is null then false else true
        for def in ques by 1
          def.reject(resp)

      .finally =>
        $timeout.cancel timeoutPromise
        timeoutPromise = null
        fetching = false
        ques = []

      deferred.promise

    @startSync = ->
      if !fetching then @fetch()
      if !fetchInterval
        fetchInterval = $interval @fetch, 1000

    return

]