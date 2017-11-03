import {
  Directive,
  ElementRef,
  Input,
  OnInit
} from '@angular/core'

import { WindowRef } from '../../services/windowref/windowref.service'

@Directive({
  selector: '[chai-full-height]',
})

export class FullHeightDirective implements OnInit {

  private jQuery: any;

  constructor(private el: ElementRef, private windowRef: WindowRef) {
    this.jQuery = this.windowRef.getJQuery()
  }

  @Input() offset: number;
  @Input('use-min') useMinHeight: boolean;

  ngOnInit() {
    let height = this.jQuery(document).height()
    if (this.offset) {
      height = height - this.offset
    }
    if (this.useMinHeight) {
      this.el.nativeElement.style.minHeight = `${height}px`
    } else {
      this.el.nativeElement.style.height = `${height}px`
    }
  }

}
