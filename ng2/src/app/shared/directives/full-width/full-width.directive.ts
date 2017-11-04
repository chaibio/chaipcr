import {
  Directive,
  ElementRef,
  Input,
  OnInit
} from '@angular/core';

import { WindowRef } from '../../services/windowref/windowref.service';

@Directive({
  selector: '[chai-full-width]'
})
export class FullWidthDirective implements OnInit {

  private jQuery: any;

  constructor(private el: ElementRef, private wref: WindowRef) {
    this.jQuery = wref.getJQuery()
  }

  @Input() offset: number;

  ngOnInit() {
    let width = this.jQuery(document).width()
    if (this.offset) {
      width = width - this.offset
    }
    this.el.nativeElement.style.width = `${width}px`
  }

}
