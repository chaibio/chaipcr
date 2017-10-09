import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'hrMinSec'
})
export class HrMinSecPipe implements PipeTransform {

  getSecondsComponents(secs: number) {

    let days, hours, mins, seconds;

    secs = secs > 0 ? secs : 0;
    secs = Math.round(secs);
    mins = Math.floor(secs / 60);
    seconds = secs - mins * 60;
    hours = Math.floor(mins / 60);
    mins = mins - hours * 60;
    days = Math.floor(hours / 24);
    hours = hours - days * 24;

    return {
      days: days || 0,
      hours: hours || 0,
      mins: mins || 0,
      seconds: seconds || 0
    }
  }

  transform(value: number): string {
    let secondsComponents = this.getSecondsComponents(value)
    let str = '';
    let secs = secondsComponents.seconds;
    let mins = secondsComponents.mins;
    let hr = secondsComponents.hours;
    let days = secondsComponents.days;

    if (secondsComponents.seconds < 10)
      secs = `0${secondsComponents.seconds}`
    if (secondsComponents.mins < 10)
      mins = `0${secondsComponents.mins}`
    if (secondsComponents.hours < 10)
      hr = `0${secondsComponents.hours}`
    if (secondsComponents.days < 10)
      days = `0${secondsComponents.days}`

    str = `${mins}:${secs}`
    if (secondsComponents.hours > 0)
      str = `${hr}:${str}` 
    if (secondsComponents.days > 0)
      str = `${days}:${str}`
    
    return str
  }

}
