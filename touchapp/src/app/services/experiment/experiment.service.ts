import { Injectable } from '@angular/core'
import { WindowRef } from '../../services/windowref/windowref.service'
import { AuthHttp } from '../auth_http/auth_http.service'
import { ExperimentList } from '../../shared/models/experiment-list.model'
import { AmplificationData } from '../../shared/models/amplification-data.model'
import { AmplificationDatum } from '../../shared/models/amplification-datum.model'
import { Experiment } from '../../shared/models/experiment.model'
import { Observable } from 'rxjs'
import { Subject } from 'rxjs'
import { map, catchError } from 'rxjs/operators'
import * as _ from 'underscore'


@Injectable()

export class ExperimentService {

  public $updates: Subject<any> = new Subject();

  constructor(private http: AuthHttp, private wref: WindowRef) { }

  getExperiments(): Observable<ExperimentList[]> {
    return this.http.get('/experiments').pipe(
      map(res => {
        let json = res.json()
        return json.map(exp => {
          return exp.experiment
        });
      })
    )
  }

  getExperiment(id: number): Observable<Experiment> {
    return this.http.get(`/experiments/${id}`).pipe(
      map((res) =>  {
        return this.extractExperiment(res);
      })
    )
  }

  deleteExperiment(id: number) {
    return this.http.delete(`/experiments/${id}`)
  }

  getAmplificationData(id: number) {
    return this.http.get(`/experiments/${id}/amplification_data`).pipe(
      map(res => {
        this.checkExperimentCompleted(res, id);
        return this.extractAmplificationData(res);
      })
    )
  }

  startExperiment(id: number) {
    let loc = this.wref.nativeWindow().location;
    return this.http.post(`${loc.protocol}//${loc.hostname}:8000/control/start`, {experiment_id: id})
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

  private checkExperimentCompleted(res, id: number):void {
    if(!res.json().partial) {
      this.$updates.next(`experiment:completed:${id}`);
    }
  }

  private extractAmplificationData(res): AmplificationData {
    let data = res.json();
    let datasets = {
      channel_1: [],
      channel_2: []
    };
    if (!data.steps) {
      return datasets;
    }
    let channel_count = 2;

    // get max cycle
    let max_cycle = _.max(_.map(data.steps, (step:any) => {
      return _.max(_.map(step.amplification_data, (ad) => {
        return ad[2];
      }));
    }));
    // end get max cycle
    data.steps.forEach((step) => {
      // remove first item containing texts
      step.amplification_data.shift();
      for (let ch=1; ch <= channel_count; ch++) {
        let dataset_name = `channel_${ch}`;
        let channel_data = _.filter(step.amplification_data, (ad) => {
          return ad[0] === ch;
        });
        for (let cycle_i=1; cycle_i <= max_cycle; cycle_i++) {
          let data_by_cycle = _.chain(channel_data)
            .filter((cd) => {
              return cd[2] === cycle_i;
            })
            .sortBy((cd) => { return cd[1]; })
            .value();

          datasets[dataset_name].push(data_by_cycle);
        }

        datasets[dataset_name] = _.chain(datasets[dataset_name])
          .filter((d: Array<any>) => {
            return d.length > 0;
          })
          .map((d: Array<any>) => {
            let datum = {
              cycle_num: d[0][2]
            };
            for(let i=0; i < d.length; i++) {
              datum[`well_${i}_background`] = d[i][3];
              datum[`well_${i}_background_log`] = d[i][3] > 10? d[i][3] : 10;
              datum[`well_${i}_baseline`] = d[i][4];
              datum[`well_${i}_baseline_log`] = d[i][4] > 10? d[i][4] : 10;
            }
            return datum;
          })
          .value();
      }
    });
    return datasets;
  }

}
