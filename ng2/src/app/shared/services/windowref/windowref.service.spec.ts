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
    expect(windowRef.nativeWindow).toBe(window)
  }))

})