import { TestBed, async, inject } from '@angular/core/testing'
import { WindowRef } from './windowref.service'

describe('WindowRef Service', () => {

  beforeEach(() => {

    TestBed.configureTestingModule({
      providers: [
        WindowRef
      ]
    })

  })

  it('should provide window object', inject([WindowRef], (windowRef: WindowRef) => {
    expect(windowRef.nativeWindow()).toBe(window)
  }))

  it('should emit window:resize event', inject([WindowRef], (windowRef: WindowRef) => {

    let resizeSpy = jasmine.createSpy('resizeSpy')
    let newWindowSize = {
      width: 100,
      height: 200
    }

    windowRef.$events.resize.subscribe(resizeSpy)

    spyOn(windowRef, 'getJQuery').and.callFake(() => {
      return () => {
        return {
          width: () => { return newWindowSize.width },
          height: () => { return newWindowSize.height }
        }
      }
    })

    let event = document.createEvent('HTMLEvents')
    event.initEvent('resize', true, false)
    window.dispatchEvent(event)

    expect(resizeSpy).toHaveBeenCalledWith(newWindowSize)

  }))

})