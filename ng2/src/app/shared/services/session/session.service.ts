import { Injectable } from '@angular/core';
import { Http, Response } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import 'rxjs/add/observable/throw';

import { BaseHttp } from '../base_http/base_http.service';
import { LoginFormData } from '../../models/login-form-data.model';

@Injectable()
export class SessionService {

  constructor(private http: BaseHttp) {}


  login (credentials: LoginFormData) {
    return this.http.post('/login', credentials)
    .map(this.extractData)
    .catch(this.handleErrorObservable)
  }

  logout() {
    return this.http.post('/logout', {}).map((res) => {
      localStorage.removeItem('token');
    });
  }

  private extractData(res: Response) {
      let body = res.json();
      localStorage.setItem('token', body.authentication_token);
      return body;
  }

  private handleErrorObservable (error: Response | any) {
    let body: string;
    try {
      let json = error.json();
      body = json.errors
    } catch (e) {
      body = 'Problem logging in'
    }
    return Observable.throw(body)
  }

}
