import { Directive, ElementRef, Output, EventEmitter, HostListener } from '@angular/core';

/** Directive to get an event when the user clicks outside of its bounds */
@Directive({
  // tslint:disable-next-line: directive-selector
  selector: '[clickOutside]'
})
export class ClickOutsideDirective {
  @Output()
  public clickOutside = new EventEmitter<MouseEvent>();

  constructor(private elementRef: ElementRef) {
  }

  @HostListener('document:click', ['$event', '$event.target'])
  public onClick(event: MouseEvent, targetElement: HTMLElement): void {
    if (!targetElement) {
      return;
    }

    const clickedInside = this.elementRef.nativeElement.contains(targetElement);
    if (!clickedInside) {
      this.clickOutside.emit(event);
    }
  }
}
