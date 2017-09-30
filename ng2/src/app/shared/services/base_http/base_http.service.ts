
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

import { WindowRef } from '../windowref/windowref.service';

@Injectable()
export class BaseHttp extends Http {

  api_port = environment.api_port;

  constructor(backend: XHRBackend, options: RequestOptions, protected windowRef: WindowRef) {
    super(backend, options);
  }

  request(url: string | Request, options?: RequestOptionsArgs): Observable<Response> {
    if (typeof url === 'string') {
      // meaning we have to add the token to the options, not in url
      url = this.appendApiPortToUrl(url)
    } else {
      // we have to add the token to the url object
      url.url = this.appendApiPortToUrl(url.url)
    }

    return super.request(url, options);
  }

  protected appendApiPortToUrl(url: string): string {
    const w = this.windowRef.nativeWindow();

    if (url.indexOf(':8000') === -1) {
      return w.location.protocol + '//' + this.windowRef.nativeWindow().location.hostname + ':' + this.api_port + url;
    } else {
      return url;
    }

  }

}

