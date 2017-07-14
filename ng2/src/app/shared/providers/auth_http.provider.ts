import {Injectable} from '@angular/core';
import {Http, XHRBackend, RequestOptions, Request, RequestOptionsArgs, Response, Headers} from '@angular/http';
import {Observable} from 'rxjs/Observable';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/catch';

@Injectable()
export class AuthHttp extends Http {

  constructor (backend: XHRBackend, options: RequestOptions) {
    super(backend, options);
  }

  request(url: string|Request, options?: RequestOptionsArgs): Observable<Response> {
    return super.request(url, options).catch(this.catchAuthError);
  }

  private catchAuthError (res: Response) {
    if (res.status === 401 || res.status === 403) {
      // if not authenticated
      console.log(res);
    }
    return Observable.throw(res);
  }
}