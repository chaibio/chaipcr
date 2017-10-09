import { Injectable } from '@angular/core'

import { AuthHttp } from '../auth_http/auth_http.service'
import { ExperimentList } from '../../models/experiment-list.model'
import { Experiment } from '../../models/experiment.model'
import { Observable } from 'rxjs/Observable'
import 'rxjs/add/operator/map'
import 'rxjs/add/operator/catch'
import 'rxjs/add/observable/throw'


@Injectable()

export class ExperimentService {

  constructor(private http: AuthHttp) { }

  getExperiments(): Observable<ExperimentList[]> {
    return this.http.get('/experiments').map(res => {
      let json = res.json()
      return json.map(exp => {
        return exp.experiment
      });
    })
  }

  getExperiment(id: number): Observable<Experiment> {
    return this.http.get(`/experiments/${id}`)
    .map((res) =>  {
      return this.extractExperiment(res);
    })
  }

  deleteExperiment(id: number) {
    return this.http.delete(`/experiments/${id}`)
  }

  private extractExperiment(res): Experiment {
    let exp = res.json().experiment;
    let result = {
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

    return result;
  }

}
