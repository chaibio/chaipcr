###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
window.App.service 'Device', [
  '$http'
  '$q'
  'host'
  'Upload'
  'Status'
  '$uibModal'
  ($http, $q, host, Upload, Status, $uibModal) ->

    class Device

      version_info = null
      is_offline = false
      capabilities = null
      is_fetching_capabilities = false
      capabilities_que = [];
      @direct_upload = false

      isOffline: -> is_offline

      getCapabilities: ->
        deferred = $q.defer()
        capabilities_que.push(deferred)
        if capabilities isnt null
          for def in capabilities_que by 1
            def.resolve capabilities
          capabilities_que = []
        else
          if !is_fetching_capabilities
            is_fetching_capabilities = true

            $http.get('/capabilities')
            .then (resp) ->
              capabilities = resp
              for def in capabilities_que by 1
                def.resolve(resp)
            .catch (resp) ->
              for def in capabilities_que by 1
                def.reject(resp)
            .finally ->
              capabilities_que = []
              is_fetching_capabilities = false

        return deferred.promise

      isDualChannel: ->
        deferred = $q.defer()
        @getCapabilities().then (resp) ->
          deferred.resolve resp.data.capabilities?.optics?.emission_channels?.length is 2
        return deferred.promise

      exportDatabase: ->
        $http.get("/device/export_database", responseType: 'arraybuffer')

      channelCount: ->
        deferred = $q.defer()
        @getCapabilities().then (resp) ->
          deferred.resolve resp.data.capabilities?.optics?.emission_channels?.length || 1
        return deferred.promise

      checkForUpdate: ->
        @direct_upload = false
        checkCloudUpdate = (deferred) =>
          cloudCheckPromise = $http.get("http://update.chaibio.com/device/software_update")
          cloudCheckPromise.then (resp) =>
            cloudInfo = resp.data
            deviceCheckPromise = @getVersion()
            deviceCheckPromise.then (device) ->
              is_offline = true
              if cloudInfo.software_version == device.software?.version
                return deferred.resolve 'unavailable'
              a_components = cloudInfo.software_version.split('.')
              b_components = device.software?.version.split('.')
              len = Math.min(a_components.length, b_components.length)
              i = 0
              while i < len
                # A bigger than B
                if parseInt(a_components[i]) > parseInt(b_components[i])
                  return deferred.resolve 'available'
                # B bigger than A
                if parseInt(a_components[i]) < parseInt(b_components[i])
                  return deferred.resolve 'unavailable'
                i++
              # If one's a prefix of the other, the longer one is greater.
              if a_components.length > b_components.length
                return deferred.resolve 'available'
              if a_components.length < b_components.length
                return deferred.resolve 'unavailable'
              return deferred.resolve 'unavailable'


              #if cloudInfo.software_version isnt device.software?.version
                #deferred.resolve 'available'
              #else
                #deferred.resolve 'unavailable'

            deviceCheckPromise.catch ->
              deferred.reject()

          cloudCheckPromise.catch ->
            deferred.reject()

        deferred = $q.defer()
        localCheckPromise = $http.post("#{host}\:8000/device/check_for_updates")
        localCheckPromise.then (resp) ->

          status = resp?.data?.device?.update_available || 'unknown'

          if status is 'unknown'
            Status.fetch()
            .then (resp) ->
              status = resp?.device?.update_available || 'unknown'
              if status is 'unknown'
                is_offline = true
                checkCloudUpdate deferred
              else
                is_offline = false
                deferred.resolve status
            .catch ->
              checkCloudUpdate deferred
          else
            deferred.resolve status

        localCheckPromise.catch =>
          is_offline = true
          checkCloudUpdate deferred

        deferred.promise

      getUpdateInfo: ->
        deferred = $q.defer()
        @getVersion(true).then (v) ->
          console.log v
          checkCloudInfo = (deferred) ->
            cloudPromise = $http.get("http://update.chaibio.com/device/software_update?v=1&model_number=#{v.model_number}&software_version=#{v.software.version}&software_platform=#{v.software.platform}&serial_number=#{v.serial_number}")
            cloudPromise.then (resp) ->
              deferred.resolve resp.data
            cloudPromise.catch (err) ->
              deferred.reject err


          Status.fetch()
          .then (resp) ->
            status = resp?.device?.update_available || 'unknown'
            if status is 'unknown'
              checkCloudInfo deferred
            else
              infoPromise = $http.get("/device/software_update?v=1&model_number=#{v.model_number}&software_version=#{v.software.version}&software_platform=#{v.software.platform}&serial_number=#{v.serial_number}")
              infoPromise.then (resp) =>
                if resp.data?.upgrade
                  deferred.resolve resp.data.upgrade
                else
                  checkCloudInfo deferred
              infoPromise.catch (err) ->
                checkCloudInfo deferred
          .catch ->
            checkCloudInfo deferred

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

      openUploadModal: ->
        @direct_upload = true;
        $uibModal.open
          templateUrl: 'app/views/settings/modal-software-update.html'
          controller: 'SoftwareUpdateCtrl'
          openedClass: 'modal-software-update-open'
          keyboard: false
          backdrop: 'static'

      openUpdateModal: ->
        @direct_upload = false
        $uibModal.open
          templateUrl: 'app/views/settings/modal-software-update.html'
          controller: 'SoftwareUpdateCtrl'
          openedClass: 'modal-software-update-open'
          keyboard: false
          backdrop: 'static'

      updateSoftware: ->
        return $http.post("#{host}\:8000/device/update_software")

      uploadImage: (file) ->
        Upload.upload
          url: "#{host}\:8000/device/upload_software_update"
          method: 'POST'
          'Content-Type': 'multipart/form-data'
          data:
            upgradefile: file

    return new Device

]
