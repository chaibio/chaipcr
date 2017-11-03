
import { destroyPlatform } from '@angular/core'
import { TestBed, inject, async } from '@angular/core/testing'
import { RouterTestingModule } from '@angular/router/testing'
import { Router } from '@angular/router'
import { HttpModule, Http, XHRBackend, Response, ResponseOptions } from '@angular/http'
import { MockBackend, MockConnection } from '@angular/http/testing'
import { Title } from '@angular/platform-browser'

import { SharedModule } from '../../shared/shared.module'
import { SessionService } from '../../shared/services/session/session.service'
import { LoginComponent } from './login.component'

describe('LoginComponent', () => {

  beforeEach(async(() => {

    destroyPlatform()

    TestBed.configureTestingModule({
      imports: [
        HttpModule,
        RouterTestingModule,
        SharedModule
      ],
      declarations: [
        LoginComponent
      ],
      providers: [
        { provide: XHRBackend, useClass: MockBackend }
      ]
    }).compileComponents()

  }))

  it('should set the title', inject([Title], (title: Title) => {
    spyOn(title, 'setTitle')
    const fixture = TestBed.createComponent(LoginComponent)
    expect(title.setTitle).toHaveBeenCalledWith('ChaiPCR | Login')
  }))

  it('should get device info', inject([Http, XHRBackend], (http: Http, backend: MockBackend) => {
    const mockResponse = {
      body: {
        data: 'mock data'
      }
    }

    backend.connections.subscribe((connection: MockConnection) => {
      connection.mockRespond(new Response(new ResponseOptions(mockResponse)))
    })

    const fixture = TestBed.createComponent(LoginComponent)
    fixture.componentInstance.ngOnInit()
    expect(fixture.componentInstance.deviceInfo).toEqual(mockResponse.body)
  }))

  it('should show login error', inject([SessionService], (sessionService: SessionService) => {

    const err = 'Error login'

    spyOn(sessionService, 'login').and.callFake(() => {
      return {
        subscribe: (successCb, errCb) => {
          errCb(err)
        }
      }
    })

    const fixture = TestBed.createComponent(LoginComponent)
    const instance = fixture.componentInstance

    instance.doSubmit()

    expect(instance.loginError).toBe(err)

  }))

  it('should redirect to home upon successful login', inject(
    [SessionService, Router],
    (sessionService: SessionService, router: Router) => {

      const err = 'Error login'

      spyOn(sessionService, 'login').and.callFake(() => {
        return {
          subscribe: (successCb, errCb) => {
            successCb()
          }
        }
      })

      spyOn(router, 'navigate').and.callThrough()

      const fixture = TestBed.createComponent(LoginComponent)
      const instance = fixture.componentInstance

      instance.doSubmit()

      expect(router.navigate).toHaveBeenCalledWith(['/'])

    }))

})

