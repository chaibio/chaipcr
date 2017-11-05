import {
  Directive,
  ElementRef,
  Input,
  OnInit,
  OnDestroy
} from '@angular/core';

import { WindowRef } from '../../services/windowref/windowref.service';
import 'rxjs/add/operator/takeUntil'
import { Subject } from 'rxjs/Subject';

@Directive({
  selector: '[chai-full-width]'
})
export class FullWidthDirective implements OnInit, OnDestroy {

  private jQuery: any;
  private ngUnsubscribe: Subject<void> = new Subject<void>()

  constructor(private el: ElementRef, private wref: WindowRef) {
    this.jQuery = wref.getJQuery()
    wref.$events.resize
      .takeUntil(this.ngUnsubscribe)
      .subscribe(() => {
        this.setWidth()
      })
  }

  @Input() offset: number;

  ngOnInit() {
    this.setWidth()
  }

  ngOnDestroy() {
    this.ngUnsubscribe.next()
    this.ngUnsubscribe.complete()
  }

  private setWidth () {
    let width = this.jQuery(document).width()
    if (this.offset) {
      width = width - this.offset
    }
    this.el.nativeElement.style.width = `${width}px`
  }

}
