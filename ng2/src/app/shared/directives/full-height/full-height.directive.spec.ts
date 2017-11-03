import {
  TestBed,
  async,
  inject,
  ComponentFixture
} from '@angular/core/testing'

import { Component } from '@angular/core'

import { WindowRef } from '../../services/windowref/windowref.service'
import { FullHeightDirective } from './full-height.directive'

describe('FullHeightDirective', () => {

  let fixture: ComponentFixture<any>;

  it('should set element height to window height', async(() => {
    @Component({
      template: `<div chai-full-height></div>`
    })
    class TestingComponent { }

    TestBed.configureTestingModule({
      providers: [
        WindowRef
      ],
      declarations: [
        TestingComponent,
        FullHeightDirective
      ]
    }).compileComponents().then(
      inject([WindowRef], (windowRef: WindowRef) => {

        let expectedHeight = 1000
        spyOn(windowRef, 'getJQuery').and.callFake(() => {
          return () => {
            return {
              height: () => {
                return expectedHeight
              }
            }
          }
        })

        fixture = TestBed.createComponent(TestingComponent)
        fixture.detectChanges()
        let el: HTMLDivElement = fixture.nativeElement.querySelector('[chai-full-height]')
        expect(el.style.height).toBe(`${expectedHeight}px`)
      }))
  }))

  it('should have height offset', async(() => {
    @Component({
      template: `<div chai-full-height offset="100"></div>`
    })
    class TestingComponent { }

    TestBed.configureTestingModule({
      providers: [
        WindowRef
      ],
      declarations: [
        TestingComponent,
        FullHeightDirective
      ]
    }).compileComponents().then(
      inject([WindowRef], (windowRef: WindowRef) => {

        let mockHeight = 1000
        spyOn(windowRef, 'getJQuery').and.callFake(() => {
          return () => {
            return {
              height: () => {
                return mockHeight
              }
            }
          }
        })

        fixture = TestBed.createComponent(TestingComponent)
        fixture.detectChanges()
        let el: HTMLDivElement = fixture.nativeElement.querySelector('[chai-full-height]')
        expect(el.style.height).toBe(`${mockHeight - 100}px`)
      }))
  }))

  describe('When use-min option is true', () => {


    it('should set element height to window height', async(() => {
      @Component({
        template: `<div chai-full-height use-min="true"></div>`
      })
      class TestingComponent { }

      TestBed.configureTestingModule({
        providers: [
          WindowRef
        ],
        declarations: [
          TestingComponent,
          FullHeightDirective
        ]
      }).compileComponents().then(
        inject([WindowRef], (windowRef: WindowRef) => {

          let expectedHeight = 1000
          spyOn(windowRef, 'getJQuery').and.callFake(() => {
            return () => {
              return {
                height: () => {
                  return expectedHeight
                }
              }
            }
          })

          fixture = TestBed.createComponent(TestingComponent)
          fixture.detectChanges()
          let el: HTMLDivElement = fixture.nativeElement.querySelector('[chai-full-height]')
          expect(el.style.minHeight).toBe(`${expectedHeight}px`)
        }))
    }))

    it('should have height offset', async(() => {
      @Component({
        template: `<div chai-full-height offset="100" use-min="true"></div>`
      })
      class TestingComponent { }

      TestBed.configureTestingModule({
        providers: [
          WindowRef
        ],
        declarations: [
          TestingComponent,
          FullHeightDirective
        ]
      }).compileComponents().then(
        inject([WindowRef], (windowRef: WindowRef) => {

          let mockHeight = 1000
          spyOn(windowRef, 'getJQuery').and.callFake(() => {
            return () => {
              return {
                height: () => {
                  return mockHeight
                }
              }
            }
          })

          fixture = TestBed.createComponent(TestingComponent)
          fixture.detectChanges()
          let el: HTMLDivElement = fixture.nativeElement.querySelector('[chai-full-height]')
          expect(el.style.minHeight).toBe(`${mockHeight - 100}px`)
        }))
    }))

  })

})
