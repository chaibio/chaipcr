import { Injectable } from '@angular/core'
import { BehaviorSubject } from 'rxjs/BehaviorSubject'
import * as $ from 'jquery'

@Injectable()
export class WindowRef {

  $events = {
    resize: new BehaviorSubject({
      width: $(this.nativeWindow()).width(),
      height: $(this.nativeWindow()).height()
    })
  }

  constructor() {
    this.nativeWindow().addEventListener('resize', () => {
      this.$events.resize.next({
        width: this.getJQuery()(this.nativeWindow()).width(),
        height: this.getJQuery()(this.nativeWindow()).height()
      })
    })
  }

  getJQuery () {
    return $
  }

  nativeWindow() {
    return window;
  }

}
