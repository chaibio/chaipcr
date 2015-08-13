window.ChaiBioTech.ngApp

.service 'Status', [
  '$http'
  '$q'
  'host'
  '$interval'
  ($http, $q, host, $interval) ->

    data = null
    @interval = null
    @listenersCount = 0

    @getData = -> data

    @fetch = ->
      deferred = $q.defer()
      $http.get("#{host}\:8000/status")
      .success (resp) =>
        data = resp
        deferred.resolve data

      .error (resp) ->
        deferred.reject(resp)

      deferred.promise

    @startSync = ->
      @listenersCount += 1

      if !@interval
        @interval = $interval @fetch, 1000

    @stopSync = ->
      @listenersCount -= 1

      if @listenersCount is 0
        $interval.cancel @interval
        @interval = null

    return

]