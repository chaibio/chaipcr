import { TestBed, inject } from '@angular/core/testing';
import { HttpModule, XHRBackend, BaseRequestOptions, RequestOptions, ResponseOptions, Response } from '@angular/http';
import { MockBackend, MockConnection } from '@angular/http/testing';
import { SessionService } from './session.service';


describe('Service: SessionService', () => {

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpModule],
      providers: [
        { provide: XHRBackend, useClass: MockBackend },
        { provide: SessionService, useClass: SessionService }
      ]
    })
  })

  describe('post /login', () => {

    it("should put authentication token to local storage", inject(
      [SessionService, XHRBackend],
      (sessionService: SessionService, backend: MockBackend) => {

        let mockResponse = {
          authentication_token: 'xxxxx'
        }

        const localStorageSetItemSpy = spyOn(localStorage, 'setItem').and.callThrough()

        backend.connections.subscribe((connection: MockConnection) => {
          connection.mockRespond(new Response(new ResponseOptions({
            status: 201,
            body: JSON.stringify(mockResponse)
          })))
        });

        sessionService.login({
          email: 'test@test.com',
          password: 'test'
        }).subscribe((res) => {
          expect(localStorageSetItemSpy).toHaveBeenCalledWith('token', mockResponse.authentication_token)
          expect(res.authentication_token).toBe(mockResponse.authentication_token)
        })

      }))

    it("should handle login errors", inject(
      [SessionService, XHRBackend],
      (sessionService: SessionService, backend: MockBackend) => {

        class MockError extends Response implements Error {
          name: any
          message: any
        }

        const mockResponse = {
          status: 401,
          body: {
            errors: 'Error message'
          }
        }

        backend.connections.subscribe((connection: MockConnection) => {
          connection.mockError(new MockError(new ResponseOptions(mockResponse)));
        });

        sessionService.login({
          email: 'test@test.com',
          password: 'test'
        }).subscribe(null, (res) => {
          expect(res).toBe(mockResponse.body.errors)
        })

      }))

    it("should handle unknown login errors", inject(
      [SessionService, XHRBackend],
      (sessionService: SessionService, backend: MockBackend) => {

        class MockError extends Response implements Error {
          name: any
          message: any
        }

        const mockResponse = {
          status: 500,
          body: ''
        }

        backend.connections.subscribe((connection: MockConnection) => {
          connection.mockError(new MockError(new ResponseOptions(mockResponse)));
        });

        sessionService.login({
          email: 'test@test.com',
          password: 'test'
        }).subscribe(null, (res) => {
          expect(res).toBe('Problem logging in')
        })

      }))


  })

});