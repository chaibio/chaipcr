import { Component, Input } from '@angular/core';

@Component({
  selector: 'ch-toggle-switch',
  templateUrl: './toggle-switch.component.html',
  styleUrls: ['./toggle-switch.component.scss']
})
export class ToggleSwitchComponent {

  @Input() checked: boolean = false

  constructor() {
  }

  changeAction(){
  	this.checked = !this.checked
  }
}
