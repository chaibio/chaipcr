import { TestBed, async } from '@angular/core/testing';

import { HrMinSecPipe } from './hr-min-secs.pipe';

describe('HrMinSecPipe', () => {

  let pipe: HrMinSecPipe;

  beforeEach(async(() => {

    pipe = new HrMinSecPipe()

  }))


  it('should transform time as HH:MM:SS', () => {
    let d = 5 * 24 * 60 * 60
    let h = 4 * 60 * 60
    let m = 3 * 60
    let s = 34
    let time = d + h + m + s
    expect(pipe.transform(time)).toBe("05:04:03:34")
  })

  it('should display 0 mins', () => {
    let s = 54
    expect(pipe.transform(s)).toBe("00:54")
  })

  it('should display mins and secs', () => {
    let m = 60
    let s = 54
    let t = m + s
    expect(pipe.transform(t)).toBe("01:54")
  })

  it('should display hrs mins and secs', () => {
    let h = 4 * 60 * 60
    let m = 3 * 60
    let s = 54
    let t = h + m + s
    expect(pipe.transform(t)).toBe("04:03:54")
  })

})
