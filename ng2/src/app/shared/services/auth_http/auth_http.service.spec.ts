import {
  TestBed,
  async,
  inject
} from '@angular/core/testing'

import { Inject } from '@angular/core'

import {
  HttpModule,
  Http,
  XHRBackend,
  RequestOptions,
  Response,
  ResponseOptions
} from '@angular/http'

import {
  MockBackend,
  MockConnection
} from '@angular/http/testing'

import { AuthHttp } from './auth_http.service'
import { WindowRef } from '../windowref/windowref.service'

const mockNativeWindow = {
  location: {
    assign: () => {}
  }
}

const windowRefMock = {
  nativeWindow: () => {
    return mockNativeWindow
  }
}

describe('AuthHttp', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      imports: [
        HttpModule
      ],
      providers: [
        { provide: XHRBackend, useClass: MockBackend },
        { provide: WindowRef, useValue: windowRefMock },
        AuthHttp,
        Window
      ]
    })

  }))


  it('should attach the authentication token to the  header', inject(
    [AuthHttp, XHRBackend],
    (auth_http: AuthHttp, backend: MockBackend) => {

      const token = '123456'

      spyOn(localStorage, 'getItem').and.returnValue(token)

      backend.connections.subscribe((connection: MockConnection) => {
        expect(connection.request.headers.get('Authorization')).toBe(`Bearer ${token}`)
      })

      auth_http.get('/experiments/1').subscribe()

    }))

  describe('when using port 8000', () => {

    it('should attach the auth token to url when url has no query params', inject(
      [AuthHttp, XHRBackend],
      (auth_http: AuthHttp, backend: MockBackend) => {

        const url = 'http://10.0.100.200:8000/status'
        const token = '123456'

        spyOn(localStorage, 'getItem').and.returnValue(token)

        backend.connections.subscribe((connection: MockConnection) => {
          expect(connection.request.url).toBe(`${url}?access_token=${token}`)
        })

        auth_http.get(url).subscribe()

      }))

    it('should attach the auth token to url when url has 1 query param', inject(
      [AuthHttp, XHRBackend],
      (auth_http: AuthHttp, backend: MockBackend) => {

        const url = 'http://10.0.100.200:8000/status?x=1'
        const token = '123456'

        spyOn(localStorage, 'getItem').and.returnValue(token)

        backend.connections.subscribe((connection: MockConnection) => {
          expect(connection.request.url).toBe(`${url}&access_token=${token}`)
        })

        auth_http.get(url).subscribe()

      }))

  })

  describe('When request is unauthenticated', () => {

    it('should redirect to login page when response is 401', inject(
      [AuthHttp, XHRBackend, WindowRef],
      (auth_http: AuthHttp, backend: MockBackend, window: WindowRef) => {

        const url = 'http://10.0.100.200:8000/status?x=1';
        spyOn(mockNativeWindow.location, 'assign')
        spyOn(localStorage, 'removeItem')

        class MockError extends Response implements Error {
          name: any
          message: any
        }

        backend.connections.subscribe((connection: MockConnection) => {
          connection.mockError(new MockError(new ResponseOptions({
            status: 401,
            body: {}
          })))
        })

        auth_http.get(url).subscribe()

        expect(window.nativeWindow().location.assign).toHaveBeenCalledWith('/login')
        expect(localStorage.removeItem).toHaveBeenCalledWith(auth_http.token_name)

      }))

  })

  describe('When request is unauthenticated', () => {

    it('should redirect to login page when response is 403', inject(
      [AuthHttp, XHRBackend, WindowRef],
      (auth_http: AuthHttp, backend: MockBackend, window: WindowRef) => {

        const url = 'http://10.0.100.200:8000/status?x=1';
        spyOn(mockNativeWindow.location, 'assign')
        spyOn(localStorage, 'removeItem')

        class MockError extends Response implements Error {
          name: any
          message: any
        }

        backend.connections.subscribe((connection: MockConnection) => {
          connection.mockError(new MockError(new ResponseOptions({
            status: 403,
            body: {}
          })))
        })

        auth_http.get(url).subscribe()

        expect(window.nativeWindow().location.assign).toHaveBeenCalledWith('/login')
        expect(localStorage.removeItem).toHaveBeenCalledWith(auth_http.token_name)

      }))

  })

})
