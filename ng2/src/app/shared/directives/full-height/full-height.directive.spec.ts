import {
  TestBed,
  async,
  inject,
  ComponentFixture
} from '@angular/core/testing'

import { WindowRef } from '../..'
import { FullHeightDirective } from './full-height.directive'

const mockWindowRef = {
  nativeWindow: {
    innerHeight: 500
  }
}

describe('FullHeightDirective', () => {

  let fixture: ComponentFixture<FullHeightDirective>;

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      providers: [
        { provide: WindowRef, useValue: mockWindowRef }
      ],
      declarations: [
        FullHeightDirective
      ]
    })

  }))

  it('should set element height to window height', async(() => {

    const template = `<div full-height></div>`

    TestBed.overrideTemplate(FullHeightDirective, template)

    TestBed

  }))

})