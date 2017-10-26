import {
  TestBed,
  async,
  inject,
  tick,
  fakeAsync,
  discardPeriodicTasks
} from '@angular/core/testing'

import {
  MockBackend,
  MockConnection
} from '@angular/http/testing'

import {
  Response,
  ResponseOptions,
  XHRBackend,
  HttpModule
} from '@angular/http'

import { AuthHttp } from '../auth_http/auth_http.service'
import { StatusService } from './status.service'
import { WindowRef } from '../windowref/windowref.service'
import { StatusData } from '../../models/status.model'
import { mockStatusReponse } from './mock-status-response'
import { initialStatusData } from './initial-status-data'

describe('StatusService', () => {

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      imports: [HttpModule],
      providers: [
        { provide: XHRBackend, useClass: MockBackend },
        WindowRef,
        AuthHttp,
        StatusService,
      ]
    })
  }))

  it('should fetch /status and emit the response', inject(
    [AuthHttp, XHRBackend, WindowRef, StatusService],
    (http: AuthHttp, backend: MockBackend, w: WindowRef, srv: StatusService) => {

      const expectedData: StatusData = {
        experiment_controller: {
          experiment: {
            id: null,
            name: null,
            estimated_duration: null,
            paused_duration: null,
            run_duration: null
          },
          machine: {
            state: 'idle',
            thermal_state: 'idle'
          }
        },
        heat_block: {
          zone1: {
            temperature: 24.6760006,
            target_temperature: 0,
            drive: -0
          },
          zone2: {
            temperature: 26.0189991,
            target_temperature: 0,
            drive: -0
          },
          temperature: 25.3470001
        },
        lid: {
          temperature: 27.0949993,
          target_temperature: 0,
          drive: 0
        },
        optics: {
          intensity: 60,
          collect_data: false,
          lid_open: false,
          well_number: 0,
          photodiode_value: [
            2538
          ]
        },
        heat_sink: {
          temperature: 26.4319992,
          fan_drive: 0
        },
        device: {
          update_available: 'unavailable'
        }
      }

      backend.connections.subscribe((con: MockConnection) => {
        con.mockRespond(new Response(new ResponseOptions({
          body: mockStatusReponse
        })))
      })

      spyOn(http, 'get').and.callThrough()

      const dataUpdateSpy = jasmine.createSpy('status:data:updated')

      srv.$data.subscribe(dataUpdateSpy)
      expect(dataUpdateSpy).toHaveBeenCalledWith(initialStatusData)
      srv.fetchData().subscribe(() => {
        expect(http.get).toHaveBeenCalledWith(`http://${w.nativeWindow().location.hostname}:8000/status`)
        expect(dataUpdateSpy).toHaveBeenCalledWith(expectedData)
      })

    }
  ))

  it('should call status.fetchData every second', inject(
    [WindowRef, StatusService],
    (wref: WindowRef, statusService: StatusService) => {
      fakeAsync(() => {
        let subscribeSpy = jasmine.createSpy('subscribeSpy')
        spyOn(statusService, 'fetchData').and.callFake(() => {
          return {
            subscribe: subscribeSpy
          }
        })
        statusService.startSync()
        tick(5000)
        expect(statusService.fetchData).toHaveBeenCalledTimes(5)
        expect(subscribeSpy).toHaveBeenCalledTimes(5)
        discardPeriodicTasks()
      })()
    }
  ))

  it('should compute the remaining time of running experiment',
    inject(
      [StatusService, XHRBackend],
      (statusService: StatusService, backend: MockBackend) => {

        let resp: any = mockStatusReponse
        resp.experiment_controller.machine.state = "running"
        resp.experiment_controller.experiment.estimated_duration = 350
        resp.experiment_controller.experiment.paused_duration = 10
        resp.experiment_controller.experiment.run_duration = 50

        backend.connections.subscribe((con: MockConnection) => {
          con.mockRespond(new Response(new ResponseOptions({
            body: resp
          })))
        })

        expect(statusService.timeRemaining()).toBe(0)
        expect(statusService.timePercentage()).toBe(0)

        statusService.fetchData().subscribe( res => {
          let exp = res.experiment_controller.experiment
          expect(statusService.timePercentage()).toBe(exp.run_duration/(exp.estimated_duration + exp.paused_duration ))
          expect(statusService.timeRemaining()).toBe((exp.run_duration + exp.paused_duration) - exp.run_duration)
        })

      }))

})
