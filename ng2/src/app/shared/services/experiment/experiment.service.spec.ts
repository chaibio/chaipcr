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
  ResponseOptions
} from '@angular/http'

import { RouterTestingModule } from '@angular/router/testing'

import {
  WindowRef,
  AuthHttp,
  ExperimentListItem
} from '../../'

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
    [ExperimentService, XHRBackend],
    (experimentService: ExperimentService, backend: MockBackend) => {

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

      backend.connections.subscribe((connection: MockConnection) => {
        expect(connection.request.url).toBe('/experiments')
        connection.mockRespond(new Response(new ResponseOptions({
          body: mockExperiments
        })))
      })

      experimentService.getExperiments().subscribe((experiments: ExperimentListItem[]) => {
        expect(experiments[0]).toEqual(mockExperiments[0].experiment)
      })

    }))

})