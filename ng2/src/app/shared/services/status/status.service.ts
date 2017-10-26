import { Injectable } from '@angular/core'
import { Response } from '@angular/http'
import { Observable } from 'rxjs/Observable'
import { BehaviorSubject } from 'rxjs/BehaviorSubject'
import 'rxjs/operator/map'

import { AuthHttp } from '../auth_http/auth_http.service'
import { WindowRef } from '../windowref/windowref.service'
import { StatusData } from '../../models/status.model'
import { initialStatusData } from './initial-status-data'

@Injectable()
export class StatusService {

  $data: BehaviorSubject<StatusData> = new BehaviorSubject(initialStatusData)
  private data: StatusData;

  constructor(private http: AuthHttp, private wref: WindowRef) {}

  fetchData(): Observable<StatusData> {
    let loc = this.wref.nativeWindow().location
    return this.http.get(`${loc.protocol}//${loc.hostname}:8000/status`)
    .map((res: Response) => {
      let data: StatusData = this.extractData(res)
      this.$data.next(data)
      this.data = data
      return data
    })
  }

  startSync() {
    this.wref.nativeWindow().setInterval(() => {
      this.fetchData().subscribe()
    }, 1000)
  }

  timePercentage(): number {
    if (!this.data) return 0
    else {
      let exp = this.data.experiment_controller.experiment
      return exp.run_duration/(exp.estimated_duration + exp.paused_duration)
    }
  }

  timeRemaining(): number {
    if (!this.data) return 0
    else {
      let exp = this.data.experiment_controller.experiment
      return (exp.run_duration + exp.paused_duration) - exp.run_duration
    }
  }

  private extractData(res: Response): StatusData {
    let data = res.json()
    // extract experiment
    if (!data.experiment_controller.experiment) {
      data.experiment_controller.experiment = {
        id: null,
        name: null,
        estimated_duration: null,
        paused_duration: null,
        run_duration: null
      }
    } else {
      let exp = data.experiment_controller.experiment
      exp.id = +exp.id
      exp.estimated_duration = +exp.estimated_duration
      exp.paused_duration = +exp.paused_duration
      exp.run_duration = +exp.run_duration
      data.experiment_controller.experiment = exp
    }
    // zone1
    data.heat_block.zone1.temperature = +data.heat_block.zone1.temperature
    data.heat_block.zone1.target_temperature = +data.heat_block.zone1.target_temperature
    data.heat_block.zone1.drive = +data.heat_block.zone1.drive
    // zone2
    data.heat_block.zone2.temperature = +data.heat_block.zone2.temperature
    data.heat_block.zone2.target_temperature = +data.heat_block.zone2.target_temperature
    data.heat_block.zone2.drive = +data.heat_block.zone2.drive
    data.heat_block.temperature = +data.heat_block.temperature
    // lid
    data.lid.temperature = +data.lid.temperature
    data.lid.target_temperature = +data.lid.target_temperature
    data.lid.drive = +data.lid.drive
    // optics
    data.optics.intensity = +data.optics.intensity
    data.optics.collect_data = data.optics.collect_data === 'true'
    data.optics.lid_open = data.optics.lid_open === 'true'
    data.optics.well_number = +data.optics.well_number
    data.optics.photodiode_value = data.optics.photodiode_value.map(v => +v)
    // heat sink
    data.heat_sink.temperature = +data.heat_sink.temperature
    data.heat_sink.fan_drive = +data.heat_sink.fan_drive
    return data
  }

}
