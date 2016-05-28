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