import { Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'ch-toggle-switch',
  templateUrl: './toggle-switch.component.html',
  styleUrls: ['./toggle-switch.component.scss']
})
export class ToggleSwitchComponent {

  private checkedValue = false;
  get checked(): boolean {
    return this.checkedValue;
  }

  @Input()
  set checked(val: boolean) {
    this.checkedValue = val;
    this.checkedChange.emit(val);
  }
  @Output() checkedChange = new EventEmitter<boolean>();
  @Output() click = new EventEmitter<any>();

  constructor() {
  }

  changeAction(){
  	this.checked = !this.checked
  	this.click.emit();
  }
}
