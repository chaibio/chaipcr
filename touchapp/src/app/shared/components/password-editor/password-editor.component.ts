import { Component, Input, Output, EventEmitter, ViewChild, ElementRef, ChangeDetectorRef } from '@angular/core';

@Component({
  selector: 'ch-password-editor',
  templateUrl: './password-editor.component.html',
  styleUrls: ['./password-editor.component.scss']
})
export class PasswordEditorComponent {

  @Input() showText: boolean = false;
  @Input() name: string;
  @Input() errorMessage: string = '';

  public _isFocusIn: boolean = false
  @Input()
  set isFocusIn(val: boolean) {
    this._isFocusIn = val;
  }

  private textValue = '';
  get text(): string {
    return this.textValue;
  }

  @Input()
  set text(val: string) {
    this.textValue = val;
    this.textChange.emit(val);
  }
  @Output() textChange = new EventEmitter<string>();
  @Output() focus = new EventEmitter<FocusEvent>();
  @Output() focusout = new EventEmitter<FocusEvent>();

  @ViewChild('textinput') textInput: ElementRef;
  @ViewChild('passwordinput') passwordInput: ElementRef;

  constructor(private changeDetector : ChangeDetectorRef) {}

  changeTextMode(){
    this.showText = !this.showText
    this.changeDetector.detectChanges()
    if(this.showText){
      this.textInput.nativeElement.focus();
    } else {
      this.passwordInput.nativeElement.focus();
    }
  }

  onInputFocus(event) {
    this.focus.emit(event);
  }

  onInputFocusOut(event) {
    this.focusout.emit(event);
  }
}
