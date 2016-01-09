window.ChaiBioTech.ngApp

.service 'Status', [
  '$http'
  '$q'
  'host'
  '$interval'
  '$timeout'
  ($http, $q, host, $interval, $timeout) ->

    data = null
    isUp = true
    fetchInterval = null
    @listenersCount = 0
    fetching = false
    timeoutPromise = null

    @getData = -> data

    @isUp = -> isUp

    @fetch = ->
      deferred = $q.defer()
      if !fetching
        fetching = true
        timeoutPromise = $timeout =>
          fetching = false
          timeoutPromise = null
        , 10000
        $http.get("#{host}\:8000/status")
        .success (resp) =>
          isUp = true
          data = resp
          deferred.resolve data

        .error (resp) ->
          console.log resp
          deferred.reject(resp)
          isUp = false

        .finally =>
          $timeout.cancel timeoutPromise
          timeoutPromise = null
          fetching = false

      else
        deferred.resolve data

      deferred.promise

    @startSync = ->
      if !fetching then @fetch()
      if !fetchInterval
        fetchInterval = $interval @fetch, 1000

    return

]