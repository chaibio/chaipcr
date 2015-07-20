window.ChaiBioTech.ngApp

.service 'Status', [
  '$http'
  '$q'
  ($http, $q) ->

    @fetch = ->
      deferred = $q.defer()
      $http.get('http://localhost\:8000/status')
      .success (data) ->
        deferred.resolve data

      .error (resp) ->
        deferred.reject(resp)

      deferred.promise

    return

]