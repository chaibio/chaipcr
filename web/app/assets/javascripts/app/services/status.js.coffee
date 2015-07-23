window.ChaiBioTech.ngApp

.service 'Status', [
  '$http'
  '$q'
  ($http, $q) ->

    hostname = window.location.hostname

    @fetch = ->
      deferred = $q.defer()
      $http.get("http://#{hostname}\:8000/status")
      .success (data) ->
        deferred.resolve data

      .error (resp) ->
        deferred.reject(resp)

      deferred.promise

    return

]