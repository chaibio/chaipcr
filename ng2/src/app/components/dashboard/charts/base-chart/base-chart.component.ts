import {
  Directive,
  ElementRef,
  Input
} from '@angular/core';

@Directive({
  selector: '[chai-base-chart]'
})
export class BaseChart {

  constructor(private el: ElementRef) {
    
  }

  @Input('data') data: any;
  @Input('config') config: any;

}
