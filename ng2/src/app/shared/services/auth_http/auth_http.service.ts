import { Injectable, Inject } from '@angular/core';
import {
  Http,
  XHRBackend,
  RequestOptions,
  Request,
  RequestOptionsArgs,
  Response,
  Headers
} from '@angular/http';

import { environment } from '../../../../environments/environment';
import { Observable } from 'rxjs/Observable';
import { BehaviorSubject } from 'rxjs/BehaviorSubject'
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/catch';
import 'rxjs/add/observable/throw';
import 'rxjs/add/observable/empty';

import { BaseHttp } from '../base_http/base_http.service';
import { WindowRef } from '../../../services/windowref/windowref.service';

@Injectable()
export class AuthHttp extends BaseHttp {

  token_name = 'token';
  authState: BehaviorSubject<boolean> = new BehaviorSubject(true);

  constructor(backend: XHRBackend, options: RequestOptions, windowRef: WindowRef) {
    super(backend, options, windowRef);
  }

  request(url: string | Request, options?: RequestOptionsArgs): Observable<Response> {
    let token = localStorage.getItem(this.token_name);
    if (typeof url === 'string') { // meaning we have to add the token to the options, not in url
      if (!options) {
        // let's make option object
        options = { headers: new Headers() };
      }
      if (url.indexOf('8000') >= 0)
        url = this.appendTokenToUrl(url)
      else
        options.headers.set('Authorization', `Bearer ${token}`);
    } else {
      // we have to add the token to the url object
      if (url.url.indexOf('8000') >= 0)
        url.url = this.appendTokenToUrl(url.url)
      else
        url.headers.set('Authorization', `Bearer ${token}`);
    }

    return super.request(url, options).catch(res => {
      return this.catchAuthError(res)
    });

  }

  protected appendTokenToUrl(url: string): string {
    let token = localStorage.getItem(this.token_name);
    if (url.indexOf('8000') >= 0) {
      let separator = url.indexOf('?') >= 0 ? '&' : '?'
      url = `${url}${separator}access_token=${token}`
    }
    return url
  }

  protected catchAuthError(res: Response) {

    if (res.status === 401 || res.status === 403) {
      localStorage.removeItem(this.token_name)
      this.windowRef.nativeWindow().location.assign('/login')
      return Observable.empty()
    }

    return Observable.throw(res);

  }

}
