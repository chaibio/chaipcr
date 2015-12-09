window.App.service 'Device', [
  '$http'
  '$q'
  ($http, $q) ->
    return new class Device

      version_info = null

      getVersion: (cache = false) ->
        deferred = $q.defer()
        if cache and version_info
          deferred.resolve version_info
        else
          promise = $http.get('/device')
          promise.then (resp) ->
            version_info = resp
            deferred.resolve resp

        return deferred.promise

]