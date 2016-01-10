window.App.service 'PeriodicUpdate', [
  '$interval'
  '$timeout'
  'Device'
  ($interval, $timeout, Device) ->
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
          last_checked = now.subtract(UPDATE_INTERVAL_DURATION.add(1, 'day'))

        next_check = last_checked.add(UPDATE_INTERVAL_DURATION)
        if  next_check.isSame(now) or now.isAfter(next_check)
          @periodicUpdateCheck()
        else
          duration = next_check.diff(now)
          $timeout @periodicUpdateCheck, duration

      periodicUpdateCheck: ->
        periodic_update_interval = $interval @periodicUpdateCheck, UPDATE_INTERVAL_DURATION if periodic_update_interval is null
        console.log "software_update_modal_instance: #{software_update_modal_instance}"
        console.log "is open modal: #{if software_update_modal_instance then true else false}"
        return if software_update_modal_instance isnt null

        console.log 'periodicUpdateCheck...'
        Device.checkForUpdate().then (is_available) ->
          $.jStorage.set 'periodic_update_last_checked', moment().format()
          if is_available is 'available' and !software_update_modal_instance
            console.log 'opening update modal..'
            software_update_modal_instance = Device.openUpdateModal()
            software_update_modal_instance.result.finally ->
              console.log 'update modal closed...'
              software_update_modal_instance = null



    new PeriodicUpdate()

]