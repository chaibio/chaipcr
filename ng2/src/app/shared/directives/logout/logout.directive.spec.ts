import { TestBed, inject, async } from '@angular/core/testing'
import { RouterTestingModule } from '@angular/router/testing'
import { Router } from '@angular/router'
import { SessionService } from '../../'
import { LogoutDirective } from './logout.directive'

import { Component } from '@angular/core'

const sessionServiceMock = {
  logout: () => {}
}

@Component({
  template: `<div logout></div>`
})
class TestingComponent {}

describe('LogoutDirective', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      imports: [
        RouterTestingModule
      ],
      declarations: [
        TestingComponent,
        LogoutDirective
      ],
      providers: [
        {
          provide: SessionService, useValue: sessionServiceMock
        }
      ]
    }).compileComponents()

  }))

  // it('should call logout when clicked', async(() => {
  //   let fixture = TestBed.createComponent(TestingComponent)
  //   let component = fixture.componentInstance

  //   spyOn(component, 'logout')

  //   fixture.detectChanges();

  //   fixture.debugElement.nativeElement.click()

  //   fixture.whenStable().then(() => {

  //     expect(component.logout).toHaveBeenCalled()
  //   })

  // }))

  it('should logout and navigate to /login', inject(
    [SessionService, Router],
    (sessionService, router: Router) => {
      let fixture = TestBed.createComponent(TestingComponent)
      let component = fixture.componentInstance

      spyOn(sessionService, 'logout').and.callFake(() => {
        return {
          subscribe: (successCb) => {
            successCb()
          }
        }
      })

      spyOn(router, 'navigate').and.returnValue(true)

      fixture.nativeElement.querySelector('[logout]').click()

      // component.logout()

      expect(sessionService.logout).toHaveBeenCalled()
      expect(router.navigate).toHaveBeenCalledWith(['/login'])


    }))

})