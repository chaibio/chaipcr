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
    isUp = false
    isUpStart = false
    isUpdating = false
    fetchInterval = null
    fetchForUpdateInterval = null
    @listenersCount = 0
    fetching = false
    fetchingForUpdate = false
    timeoutPromise = null
    ques = []

    @getData = -> data

    @isUp = -> isUp

    @isUpdating = -> isUpdating

    @fetch = ->
      deferred = $q.defer()
      ques.push deferred

      if fetching
        return deferred.promise
      else
        fetching = true

        timeoutPromise = $timeout =>
          timeoutPromise = null
          fetching = false
        , 10000
        $http.get("/device/status")
        .success (resp) =>
          #console .log isUp
          #isUp = true
          oldData = angular.copy data
          data = resp
          for def in ques by 1
            def.resolve data

          if data?.experiment_controller?.machine?.state is 'idle' and oldData?.experiment_controller?.machine?.state isnt 'idle'
            $rootScope.$broadcast 'status:experiment:completed'

          $rootScope.$broadcast 'status:data:updated', data, oldData

        .error (resp) ->
          #isUp = if resp is null then false else true
          for def in ques by 1
            def.reject(resp)

        .finally =>
          $timeout.cancel timeoutPromise
          timeoutPromise = null
          fetching = false
          ques = []

      deferred.promise

    @fetchForUpdate = ->
      isUpdating = true
      $http.get("/experiments")
      .success (resp) =>
        console .log isUp
        isUp = if isUpStart then true else false
        if isUp
          $interval.cancel fetchForUpdateInterval

      .error (resp, status) ->
        console.log status
        isUpStart = true
        isUp = if status == 401 then true else false
        if isUp
          $interval.cancel fetchForUpdateInterval

      true

    @startSync = ->
      if !fetching then @fetch()
      if !fetchInterval
        fetchInterval = $interval @fetch, 1000

    @stopSync = ->
      if (fetchInterval)
        $interval.cancel(fetchInterval)

    @startUpdateSync = ->
      fetchForUpdateInterval = $interval @fetchForUpdate, 1000

    return

]
