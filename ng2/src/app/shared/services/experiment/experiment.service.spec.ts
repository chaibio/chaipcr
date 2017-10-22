import {
  TestBed,
  async,
  inject
} from '@angular/core/testing';

import {
  MockBackend,
  MockConnection
} from '@angular/http/testing';

import {
  Http,
  HttpModule,
  XHRBackend,
  Response,
  ResponseOptions,
  RequestMethod
} from '@angular/http';

import { RouterTestingModule } from '@angular/router/testing';

import { WindowRef } from '../../services/windowref/windowref.service';
import { ExperimentList } from '../../models/experiment-list.model';
import { AmplificationData } from '../../models/amplification-data.model';
import { AuthHttp } from '../../services/auth_http/auth_http.service';
import { ExperimentService } from './experiment.service';
import { } from '../../models/amplification-data.model';

import { Experiment } from '../../models/experiment.model';
import { mockExperimentResponse } from './mock-experiment.response';
import { MockAmplificationDataResponse } from './mock-amplification-data.response';

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
        for (let i = 0; i < experiments.length; i ++) {
          expect(experiments[i]).toEqual(mockExperiments[i].experiment)
        }
      })

      expect(auth_http.get).toHaveBeenCalledWith('/experiments')

    }))

  it('should get single experiment', inject(
    [ExperimentService, XHRBackend, AuthHttp],
    (expService: ExperimentService, backend: MockBackend, auth_http: AuthHttp) => {

      let exp = mockExperimentResponse.experiment;

      let result: Experiment = {
        id: exp.id,
        name: exp.name,
        type: exp.type,
        time_valid: exp.time_valid,
        started_at: exp.started_at,
        created_at: exp.started_at,
        completed_at: exp.completed_at,
        completion_status: exp.completion_status,
        completion_message: exp.completion_message,
        protocol: {
          id: exp.protocol.id,
          estimate_duration: exp.protocol.estimate_duration,
          lid_temperature: +exp.protocol.lid_temperature,
          stages: []
        }
      };

      exp.protocol.stages.forEach((s) => {
        let stage: any = {
          id: s.stage.id,
          name: s.stage.name,
          num_cycles: s.stage.num_cycles,
          order_number: s.stage.order_number,
          stage_type: s.stage.stage_type,
          auto_delta: s.stage.auto_delta,
          auto_delta_start_cycle: s.stage.auto_delta_start_cycle,
          steps: []
        };
        s.stage.steps.forEach((step) => {
          let nstep:any = step.step
          nstep.temperature = +step.step.temperature;
          nstep.delta_temperature = +step.step.delta_temperature;
          nstep.ramp.rate = +nstep.ramp.rate;

          stage.steps.push(nstep);

        })
        result.protocol.stages.push(stage);
      })

      let exptedResult: Experiment = result;

      backend.connections.subscribe((con: MockConnection) => {
        con.mockRespond(new Response(new ResponseOptions({
          body: mockExperimentResponse
        })))
      })

      spyOn(auth_http, 'get').and.callThrough();

      expService.getExperiment(1).subscribe((res: Experiment) => {
        expect(res).toEqual(result)
      })

      expect(auth_http.get).toHaveBeenCalledWith(`/experiments/1`)

    }
  ))

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

  it('should fetch amplification data', inject(
    [ExperimentService, XHRBackend, AuthHttp],
    (expService: ExperimentService, backend: MockBackend, http: AuthHttp) => {

      const expId = 1;
      const backendSpy = jasmine.createSpy('backendSpy');
      const resp:any = Object.assign({}, MockAmplificationDataResponse)

      backend.connections.subscribe((con: MockConnection) => {
        expect(con.request.method).toBe(RequestMethod.Get);
        con.mockRespond(new Response(new ResponseOptions({
          body: resp
        })));
        backendSpy();
      })

      spyOn(http, 'get').and.callThrough();

      expService.getAmplificationData(expId).subscribe((data: AmplificationData) => {
        //console.log(data.channel_1[1]);
        // assert background subtracted value
        expect(data.channel_1[1].well_0_background).toBe(resp.steps[0].amplification_data[3])
        // assert cycle number
        expect(data.channel_1[1].cycle_num).toEqual(resp.steps[0].amplification_data[2])
      })

      expect(http.get).toHaveBeenCalledWith(`/experiments/${expId}/amplification_data`);

      expect(backendSpy).toHaveBeenCalled();

    }
  ))

})
