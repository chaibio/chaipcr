import {
  TestBed,
  async,
  inject
} from '@angular/core/testing'

import {
  MockBackend,
  MockConnection
} from '@angular/http/testing'

import {
  Http,
  HttpModule,
  XHRBackend,
  Response,
  ResponseOptions,
  RequestMethod
} from '@angular/http'

import { RouterTestingModule } from '@angular/router/testing'

import { WindowRef } from '../../services/windowref/windowref.service'
import { ExperimentList } from '../../models/experiment-list.model'
import { AuthHttp } from '../../services/auth_http/auth_http.service'
import { ExperimentService } from './experiment.service'

describe('ExperimentService', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      imports: [
        RouterTestingModule,
        HttpModule
      ],
      providers: [
        { provide: XHRBackend, useClass: MockBackend },
        AuthHttp,
        ExperimentService,
        WindowRef,
      ]
    })

  }))

  it('should get all experiments', inject(
    [ExperimentService, XHRBackend, AuthHttp],
    (experimentService: ExperimentService, backend: MockBackend, auth_http: AuthHttp) => {

      const mockExperiments = [
        {
          experiment: {
            id: 6,
            name: "Water",
            time_valid: true,
            completed_at: "2016-02-25T00:26:17.000Z",
            completion_message: "",
            completion_status: "success",
            created_at: "2016-02-25T00:23:57.000Z",
            started_at: "2016-02-25T00:24:09.000Z",
            type: "user"
          }
        },
        {
          experiment: {
            id: 7,
            name: "Water",
            time_valid: true,
            completed_at: "2016-02-25T00:26:17.000Z",
            completion_message: "",
            completion_status: "success",
            created_at: "2016-02-25T00:23:57.000Z",
            started_at: "2016-02-25T00:24:09.000Z",
            type: "user"
          }
        },
      ]

      spyOn(auth_http, 'get').and.callThrough()

      backend.connections.subscribe((connection: MockConnection) => {
        connection.mockRespond(new Response(new ResponseOptions({
          body: mockExperiments
        })))
      })

      experimentService.getExperiments().subscribe((experiments: ExperimentList[]) => {
        expect(experiments[0]).toEqual(mockExperiments[0].experiment)
      })

      expect(auth_http.get).toHaveBeenCalledWith('/experiments')

    }))

  it('should delete experiment', inject(
    [ExperimentService, XHRBackend, AuthHttp],
    (expService: ExperimentService, backend: MockBackend, auth_http: AuthHttp) => {

      const expId = 1

      const backendSpy = jasmine.createSpy('backendSpy')

      backend.connections.subscribe((connection: MockConnection) => {
        expect(connection.request.method).toBe(RequestMethod.Delete)
        //expect(connection.request.url).toBe(`/experiments/${expId}`)
        connection.mockRespond(new Response(new ResponseOptions({
          status: 200,
          body: {
            status: true
          }
        })))
        backendSpy()
      })

      spyOn(auth_http, 'delete').and.callThrough()

      expService.deleteExperiment(expId).subscribe(resp => {
        expect(backendSpy).toHaveBeenCalled()
      })

      expect(auth_http.delete).toHaveBeenCalledWith(`/experiments/${expId}`)

    }
  ))

})
