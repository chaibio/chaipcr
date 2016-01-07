


window.App.service 'Device', [
  '$http'
  '$q'
  'host'
  'Upload'
  ($http, $q, host, Upload) ->

    class Device

      version_info = null

      checkForUpdate: ->
        $http.get('/device/software_update')

      checkCloudUpdate: ->
        $http.get("http://update.chaibio.com/device/software_update")

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
        return $http.post("#{host}\:8000/device/update_software")

      uploadImage: (file) ->
        Upload.upload
          url: "#{host}\:8000/device/upload_software_update"
          method: 'POST'
          data: file

    return new Device

]