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
    @fetching = false

    @getData = -> data

    @fetch = ->
      deferred = $q.defer()
      if !@fetching
        @fetching = true
        $http.get("#{host}\:8000/status")
        .success (resp) =>
          data = resp
          deferred.resolve data

        .error (resp) ->
          deferred.reject(resp)

        .finally ->
          @fetching = false

      else
        deferred.resolve data

      deferred.promise

    @startSync = ->
      @listenersCount += 1

      if !@fetching then @fetch()

      if !@interval
        @interval = $interval @fetch, 3000

    @stopSync = ->
      @listenersCount -= 1

      if @listenersCount is 0
        $interval.cancel @interval
        @interval = null

    return

]