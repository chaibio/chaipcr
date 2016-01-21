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
      , 10000
      $http.get("#{host}\:8000/status")
      .success (resp) =>
        isUp = true
        data = resp

        for def in ques by 1
          def.resolve data

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