window.ChaiBioTech.ngApp

.service 'SecondsDisplay', [
  ->
    @getSecondsComponents = (secs) ->
      days = 0
      hours = 0
      mins = 0
      seconds = 0
      for sec in [0...secs] by 1
        ++ seconds

        if seconds is 60
          ++ mins
          seconds = 0

        if mins is 60
          ++ hours
          mins = 0

        if hours is 24
          ++ days
          hours = 0

      days: days
      hours: hours
      mins: mins
      seconds: seconds

    @display1 = (seconds) =>
      sec = @getSecondsComponents seconds

      text = ''

      if sec.days > 0
        text = "#{text} #{sec.days} #{if sec.days > 1 then 'days' else 'day'}"

      if sec.hours > 0
        text = "#{text} #{sec.hours} hr"

      if sec.mins > 0
        text = "#{text} #{sec.mins} min"

      if sec.days is 0 and sec.hours is 0 and sec.mins is 0
        text = "#{text} #{sec.seconds} sec"

      text

    @display2 = (seconds) =>
      sec = @getSecondsComponents seconds

      text = ''

      if sec.days < 10
        sec.days = "0#{sec.days}"

      if sec.hours < 10
        sec.hours = "0#{sec.hours}"

      if sec.mins < 10
        sec.mins = "0#{sec.mins}"

      if sec.seconds < 10
        sec.seconds = "0#{sec.seconds}"

      "#{if (parseInt sec.days) > 0 then sec.days+':' else ''}#{sec.hours}:#{sec.mins}:#{sec.seconds}"

    return
]