import {Injectable} from '@angular/core';
import {Http, Response} from '@angular/http';
import {Observable} from 'rxjs';

@Injectable()
export class SessionService {

  constructor(private http: Http) {}


  login (credentials) {
    return this.http.post('/login', credentials)
    .map(this.extractData)
    .catch(this.handleErrorObservable)
  }

  private extractData(res: Response) {
      let body = res.json();
      localStorage.setItem('token', body.authentication_token);
      return body;
  }

  private handleErrorObservable (error: Response | any) {
      let body = error.json();
      return Observable.throw(body.errors || body);
  }

}