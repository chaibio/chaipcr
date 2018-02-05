import { Injectable } from '@angular/core'
import { BehaviorSubject } from 'rxjs/BehaviorSubject'
import * as $ from 'jquery'

@Injectable()
export class WindowRef {

  constructor() {
    console.log('WindowRef')
    //this.initEventHandlers();
  }

  getJQuery () {
    return $
  }

  nativeWindow() {
    return window;
  }

}
