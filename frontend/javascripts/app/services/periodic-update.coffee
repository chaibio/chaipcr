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
            Device.checkForUpdate().then (resp) ->
              status = resp?.device?.update_available || 'unknown'
              openUpdateModal(status) if status is 'available'
          else
            openUpdateModal(status) if status is 'available'

    new PeriodicUpdate()

]