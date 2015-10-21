window.ChaiBioTech.ngApp

.service 'SecondsDisplay', [
  ->
    @getSecondsComponents = (secs) ->
      secs = Math.round secs

      mins = Math.floor(secs / 60);
      seconds = secs - mins * 60;
      hours = Math.floor(mins/60);
      mins = mins - hours * 60
      days = Math.floor hours/24
      hours = hours - days * 24

      days: days || 0
      hours: hours || 0
      mins: mins || 0
      seconds: seconds || 0

    @display1 = (seconds) =>
      sec = @getSecondsComponents seconds

      text = ''

      if sec.days > 0
        text = "#{text} #{sec.days} d"

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

    @display3 = (seconds) =>
      seconds = @getSecondsComponents seconds
      text = ''

      if seconds.days > 0
        text = "#{text} #{seconds.days}d"

      if seconds.hours > 0
        text = "#{text} #{seconds.hours}hr"

      if seconds.days is 0 and seconds.mins > 0
        text = "#{text} #{seconds.mins}m"

      if seconds.days is 0 and seconds.hours is 0
        text = "#{text} #{seconds.seconds}s"

      text

    return
]