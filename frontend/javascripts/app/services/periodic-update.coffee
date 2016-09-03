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
window.App.service 'PeriodicUpdate', [
  '$interval'
  '$timeout'
  'Device'
  'Status'
  ($interval, $timeout, Device, Status) ->
    class PeriodicUpdate


      software_update_modal_instance = null
      periodic_update_interval = null
      UPDATE_INTERVAL_DURATION = moment.duration 4, 'hours'


      init: ->
        last_checked = $.jStorage.get 'periodic_update_last_checked'
        now = moment()

        if last_checked
          last_checked = moment(last_checked)
        else
          last_checked = now.subtract(UPDATE_INTERVAL_DURATION.add(1, 'days'))

        next_check = last_checked.add(UPDATE_INTERVAL_DURATION)
        if  next_check.isSame(now) or now.isAfter(next_check)
          @periodicUpdateCheck()
        else
          duration = next_check.diff(now)
          $timeout @periodicUpdateCheck, duration

      openUpdateModal = (status) ->
        if !software_update_modal_instance
          software_update_modal_instance = Device.openUpdateModal()
          software_update_modal_instance.result.finally ->
            software_update_modal_instance = null

      periodicUpdateCheck: ->
        periodic_update_interval = $interval @periodicUpdateCheck, UPDATE_INTERVAL_DURATION if !periodic_update_interval
        return if software_update_modal_instance isnt null
        $.jStorage.set 'periodic_update_last_checked', moment().format()

        Status.fetch().then (resp) ->
          status = resp?.device?.update_available || 'unknown'
          if status is 'unknown'
            if resp.device.update_error
              openUpdateModal(status)
            else
              Device.checkForUpdate().then (resp) ->
                status = resp?.device?.update_available || 'unknown'
                openUpdateModal(status) if status is 'available'
          else
            openUpdateModal(status) if status is 'available'

    new PeriodicUpdate()

]
