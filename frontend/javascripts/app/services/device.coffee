


window.App.service 'Device', [
  '$http'
  '$q'
  'host'
  ($http, $q, host) ->

    class Device

      version_info = null

      checkForUpdate: ->
        $http.get('/device/software_update')

      getVersion: (cache = false) ->
        deferred = $q.defer()
        if cache and version_info
          deferred.resolve version_info
        else
          promise = $http.get('/device')
          promise.then (resp) ->
            version_info = resp.data
            deferred.resolve resp.data
          promise.catch (resp) ->
            deferred.reject resp

        return deferred.promise

      updateSoftware: ->
        return $http.post("/device/update_software")

    return new Device

]