
window.App.service 'Device', [
  '$http'
  '$q'
  'host'
  'Upload'
  ($http, $q, host, Upload) ->

    class Device

      version_info = null

      checkForUpdate: ->
        deferred = $q.defer()
        localCheckPromise = $http.get('/device/software_update')
        localCheckPromise.then (resp) ->
          deferred.resolve resp.data.upgrade
        localCheckPromise.catch =>
          cloudCheckPromise = $http.get("http://update.chaibio.com/device/software_update")
          cloudCheckPromise.then (resp) =>
            cloudInfo = resp.data
            deviceCheckPromise = @getVersion()
            deviceCheckPromise.then (device) ->
              if cloudInfo.software_version isnt device.software.version
                new_update =
                  is_offline: true
                  image_url: cloudInfo.image_url
                  brief_description: cloudInfo.brief_description
                  full_description: cloudInfo.full_description
                  release_date: cloudInfo.release_date
                  version: cloudInfo.software_version
                deferred.resolve new_update
              else
                deferred.resolve({})

            deviceCheckPromise.catch ->
              deferred.reject()

          cloudCheckPromise.catch ->
            deferred.reject()

        deferred.promise

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