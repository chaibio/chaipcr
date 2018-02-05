import {
  Directive,
  ElementRef,
  Input,
  OnInit,
  OnDestroy,
  HostListener
} from '@angular/core';

import { WindowRef } from '../../../services/windowref/windowref.service';
import 'rxjs/add/operator/takeUntil'
import { Subject } from 'rxjs/Subject';

@Directive({
  selector: '[chai-full-width]'
})
export class FullWidthDirective implements OnInit {

  @Input() offset: number;
  @HostListener('window:resize', ['$event'])
  setWidth () {
    let width = this.jQuery(document).width()
    if (this.offset) {
      width = width - this.offset
    }
    this.el.nativeElement.style.width = `${width}px`
  }

  private jQuery: any;

  constructor(private el: ElementRef, private wref: WindowRef) {
    this.jQuery = wref.getJQuery()
  }

  ngOnInit() {
    this.setWidth()
  }


}
