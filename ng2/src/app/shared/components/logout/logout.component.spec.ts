import { TestBed, inject, async } from '@angular/core/testing'
import { RouterTestingModule } from '@angular/router/testing'
import { Router } from '@angular/router'
import { SessionService } from '../../services/session.service'
import { LogoutComponent } from './logout.component'

class SessionServiceMock {

  logout() {

  }

}

describe('LogoutComponent', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      imports: [
        RouterTestingModule
      ],
      declarations: [
        LogoutComponent
      ],
      providers: [
        {
          provide: SessionService, useClass: SessionServiceMock
        }
      ]
    }).compileComponents()

  }))

  it('should call logout when clicked', async(() => {
    let fixture = TestBed.createComponent(LogoutComponent)
    let component = fixture.componentInstance

    spyOn(component, 'logout')

    fixture.detectChanges();

    fixture.debugElement.nativeElement.click()

    fixture.whenStable().then(() => {

      expect(component.logout).toHaveBeenCalled()
    })

  }))

  it('should call sessionService.logout() and navigate to /login', inject(
    [SessionService, Router],
    (sessionService: SessionServiceMock, router: Router) => {
      let fixture = TestBed.createComponent(LogoutComponent)
      let component = fixture.componentInstance

      spyOn(sessionService, 'logout').and.callFake(() => {
        return {
          subscribe: (successCb) => {
            successCb()
          }
        }
      })

      spyOn(router, 'navigate').and.returnValue(true)

      component.logout()

      expect(sessionService.logout).toHaveBeenCalled()
      expect(router.navigate).toHaveBeenCalledWith(['/login'])


    }))

})