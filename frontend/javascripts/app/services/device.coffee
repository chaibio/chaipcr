    # from cloud info to
    # new_update =
    #   is_offline: true
    #   image_url: cloudInfo.image_url
    #   brief_description: cloudInfo.brief_description
    #   full_description: cloudInfo.full_description
    #   release_date: cloudInfo.release_date
    #   version: cloudInfo.software_version


window.App.service 'Device', [
  '$http'
  '$q'
  'host'
  'Upload'
  'Status'
  ($http, $q, host, Upload, Status) ->

    class Device

      version_info = null

      checkForUpdate: ->

        checkCloudUpdate = (deferred) =>
          cloudCheckPromise = $http.get("http://update.chaibio.com/device/software_update")
          cloudCheckPromise.then (resp) =>
            cloudInfo = resp.data
            deviceCheckPromise = @getVersion()
            deviceCheckPromise.then (device) ->
              if cloudInfo.software_version isnt device.software.version
                deferred.resolve 'available'
              else
                deferred.resolve 'unavailable'

            deviceCheckPromise.catch ->
              deferred.reject()

          cloudCheckPromise.catch ->
            deferred.reject()

        deferred = $q.defer()
        localCheckPromise = $http.post("#{host}\:8000/device/check_for_updates")
        localCheckPromise.then ->
          status = (Status.getData()?.device?.update_available) || 'unknown'
          if status is 'unknown'
            checkCloudUpdate deferred
          else
            deferred.resolve status
        localCheckPromise.catch =>
          checkCloudUpdate deferred

        deferred.promise

      getUpdateInfo: ->
        deferred = $q.defer()
        infoPromise = $http.get('/device/software_update')
        infoPromise.then (resp) ->
          deferred.resolve resp.data.upgrade
        infoPromise.catch (err) ->
          deferred.reject err

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