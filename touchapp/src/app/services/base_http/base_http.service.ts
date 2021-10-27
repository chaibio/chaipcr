
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

import { environment } from '../../../environments/environment';
import { Observable } from 'rxjs';
import { BehaviorSubject } from 'rxjs'

import { WindowRef } from '../windowref/windowref.service';

@Injectable()
export class BaseHttp extends Http {

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
      return w.location.protocol + '//' + this.windowRef.nativeWindow().location.hostname + ':' + environment.api_port + url;
    } else {
      return url;
    }

  }

}

