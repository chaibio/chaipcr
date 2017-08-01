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

  constructor(private http: AuthHttp, private wref: WindowRef) {}

  fetchData(): Observable<StatusData> {
    return this.http.get(`http://${this.wref.nativeWindow().location.hostname}:8000/status`)
      .map((res: Response) => {
        let data: StatusData = this.extractData(res)
        this.$data.next(data)
        return data
      })
  }

  startSync() {
    this.wref.nativeWindow().setInterval(() => {
      this.fetchData()
    }, 1000)
  }

  private extractData(res: Response): StatusData {
    let data = res.json()
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
    data.optics.collect_data = data.optics.collect_data === 'true' ? true : false
    data.optics.lid_open = data.optics.lid_open === 'true' ? true : false
    data.optics.well_number = +data.optics.well_number
    data.optics.photodiode_value = data.optics.photodiode_value.map(v => +v)
    // heat sink
    data.heat_sink.temperature = +data.heat_sink.temperature
    data.heat_sink.fan_drive = +data.heat_sink.fan_drive
    return data
  }

}