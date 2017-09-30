import {
  TestBed,
  async,
  inject
} from '@angular/core/testing'

import { Inject } from '@angular/core'
import { environment } from '../../../../environments/environment'

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

import { BaseHttp } from './base_http.service'
import { WindowRef } from '../windowref/windowref.service'

const mockNativeWindow = {
  location: {
    assign: () => {},
    hostname: window.location.hostname,
    port: window.location.port,
    protocol: 'http:'
  }
}

const windowRefMock = {
  nativeWindow: () => {
    return mockNativeWindow
  }
}

describe('BaseHttp', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      imports: [
        HttpModule
      ],
      providers: [
        { provide: XHRBackend, useClass: MockBackend },
        { provide: WindowRef, useValue: windowRefMock },
        BaseHttp,
        Window
      ]
    })

  }))

  it('should add port to url', inject(
    [BaseHttp, XHRBackend, WindowRef],
    (base_http: BaseHttp, backend: MockBackend, windowRef: WindowRef) => {

      const PORT = environment.api_port;
      const url = '/test'
      const w = windowRef.nativeWindow()

      expect(base_http.api_port).toBe(PORT)

      backend.connections.subscribe((con: MockConnection) => {
        expect(con.request.url).toBe(w.location.protocol + '//' +w.location.hostname + ':' + PORT + url)
      })

      base_http.get(url).subscribe()

    }
  ))

  it('should not add port to url if url is in 8000 port', inject(
    [BaseHttp, XHRBackend, WindowRef],
    (base_http: BaseHttp, backend: MockBackend, windowRef: WindowRef) => {

      const url = 'http://' + windowRef.nativeWindow().location.hostname + ':8000/status'

      backend.connections.subscribe((con: MockConnection) => {
        expect(con.request.url).toBe(url)
      })

      base_http.get(url).subscribe()

    }))

})

