import { Injectable } from '@angular/core'
import { Response } from '@angular/http'
import { Observable, BehaviorSubject } from 'rxjs'
import { map, catchError } from 'rxjs/operators'

import { AuthHttp } from '../auth_http/auth_http.service'
import { WindowRef } from '../../services/windowref/windowref.service'
import { StatusData } from '../../shared/models/status.model'
import { initialStatusData } from './initial-status-data'

@Injectable()
export class StatusService {

  $data: BehaviorSubject<StatusData> = new BehaviorSubject(initialStatusData)
  private data: StatusData;
  private fetchInterval: any;

  constructor(private http: AuthHttp, private wref: WindowRef) {}

  fetchData(): Observable<StatusData> {
    let loc = this.wref.nativeWindow().location
    return this.http.get(`${loc.protocol}//${loc.hostname}:8000/status`).pipe(
      map((res: Response) => {
        let data: StatusData = this.extractData(res)
        this.$data.next(data)
        this.data = data
        return data
      })
    )
  }

  startSync() {
    this.fetchInterval = this.wref.nativeWindow().setInterval(() => {
      this.fetchData().subscribe();
    }, 1000)
  }

  stopSync() {
    this.wref.nativeWindow().clearInterval(this.fetchInterval)
  }

  timePercentage(): number {
    if (!this.data) return 0
    else {
      let exp = this.data.experiment_controller.experiment
      return exp.run_duration / (exp.estimated_duration + exp.paused_duration)
    }
  }

  timeRemaining(): number {
    if (!this.data) return 0
    else {
      let exp = this.data.experiment_controller.experiment
      return (exp.estimated_duration + exp.paused_duration) - exp.run_duration
    }
  }

  private extractData(res: Response): StatusData {
    let data = res.json()
    return data
  }

}
