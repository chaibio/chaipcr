import {
  TestBed,
  async,
  inject
} from '@angular/core/testing'

import {
  HttpModule,
  Http,
  XHRBackend,
  RequestOptions
} from '@angular/http'

import {
  MockBackend,
  MockConnection
} from '@angular/http/testing'

import { AuthHttp } from './auth_http.service'

describe('AuthHttp', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      imports: [
        HttpModule
      ],
      providers: [
        { provide: XHRBackend, useClass: MockBackend },
        AuthHttp
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

})