import {
  TestBed,
  async,
  inject
} from '@angular/core/testing';
import { Component } from '@angular/core';
import { WindowRef } from '../../services/windowref/windowref.service';
import { FullWidthDirective } from './full-width.directive';
import { BehaviorSubject } from 'rxjs/BehaviorSubject'

let width = 1024;
const height = 800;
const mockWindowRef: any = {
  getJQuery: () => {},
  $events: {
    resize: new BehaviorSubject({
      width: width,
      height: height
    })
  }
}

let jQuerySpy: any;

describe('FullWidth Directive', () => {

  beforeEach(async(() => {

    jQuerySpy = jasmine.createSpy('jQuery').and.callFake(selector => {
      return {
        width: () => { return width }
      }
    })

    spyOn(mockWindowRef, 'getJQuery').and.callFake(jasmine.createSpy('getJQuery').and.callFake((selector) => {
      return jQuerySpy;
    }))

  }))

  it('should set elem to full window width', async(() => {

    @Component({
      template: '<div chai-full-width></div>'
    })
    class TestingComponent {}

    TestBed.configureTestingModule({
      declarations: [
        FullWidthDirective,
        TestingComponent
      ],
      providers: [
        {provide: WindowRef, useValue: mockWindowRef}
      ]
    }).compileComponents().then(inject(
      [WindowRef],
      (wref: WindowRef) => {

        let fixture = TestBed.createComponent(TestingComponent)
        fixture.detectChanges()
        let el = fixture.debugElement.nativeElement.querySelector('[chai-full-width]')

        expect(jQuerySpy).toHaveBeenCalledWith(document)
        expect(el.style.width).toBe(`${width}px`)

      }
    ))

  }))

  it('should NOT set elem to full window width when offset option is present', async(() => {

    @Component({
      template: '<div chai-full-width offset="30"></div>'
    })
    class TestingComponent {}

    TestBed.configureTestingModule({
      declarations: [
        FullWidthDirective,
        TestingComponent
      ],
      providers: [
        {provide: WindowRef, useValue: mockWindowRef}
      ]
    }).compileComponents().then(inject(
      [WindowRef],
      (wref: WindowRef) => {

        let fixture = TestBed.createComponent(TestingComponent)
        fixture.detectChanges()
        let el = fixture.debugElement.nativeElement.querySelector('[chai-full-width]')

        expect(jQuerySpy).toHaveBeenCalledWith(document)
        expect(el.style.width).toBe(`${width - 30}px`)

      }
    ))

  }))

  it('should resize during window:resize event', async(() => {

    @Component({
      template: '<div chai-full-width offset="30"></div>'
    })
    class TestingComponent {}

    TestBed.configureTestingModule({
      declarations: [
        FullWidthDirective,
        TestingComponent
      ],
      providers: [
        {provide: WindowRef, useValue: mockWindowRef}
      ]
    }).compileComponents().then(inject(
      [WindowRef],
      (wref: WindowRef) => {

        let fixture = TestBed.createComponent(TestingComponent)
        fixture.detectChanges()
        let el = fixture.debugElement.nativeElement.querySelector('[chai-full-width]')

        expect(jQuerySpy).toHaveBeenCalledWith(document)
        expect(el.style.width).toBe(`${width - 30}px`)

        width = 500

        wref.$events.resize.next({
          width: width,
          height: height
        })

        fixture.detectChanges()
        el = fixture.debugElement.nativeElement.querySelector('[chai-full-width]')

        expect(el.style.width).toBe(`${width - 30}px`)

      }
    ))

  }))

})
