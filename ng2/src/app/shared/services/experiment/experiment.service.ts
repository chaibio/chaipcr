import { Injectable } from '@angular/core'

import { AuthHttp } from '../auth_http/auth_http.service'
import { ExperimentListItem } from '../../models/experiment-list-item.model'
import { Observable } from 'rxjs/Observable'
import 'rxjs/add/operator/map'
import 'rxjs/add/operator/catch'
import 'rxjs/add/observable/throw'


@Injectable()

export class ExperimentService {

  constructor(private http: AuthHttp) { }

  getExperiments(): Observable<ExperimentListItem[]> {
    return this.http.get('/experiments').map(res => {
      let json = res.json()
      return json.map(exp => {
        return exp.experiment
      });
    })
  }

}