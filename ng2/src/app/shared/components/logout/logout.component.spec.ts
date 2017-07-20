import { TestBed, inject, async } from '@angular/core/testing'
import { RouterTestingModule } from '@angular/router/testing'
import { Router } from '@angular/router'
import { SessionService } from '../../'
import { LogoutComponent } from './logout.component'

const sessionServiceMock = {
  logout: () => {}
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
          provide: SessionService, useValue: sessionServiceMock
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
    (sessionService, router: Router) => {
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