import { Component, Input } from '@angular/core';

@Component({
  selector: 'setting-breadcrumbs',
  templateUrl: './breadcrumbs.component.html',
  styleUrls: ['./breadcrumbs.component.scss']
})
export class SettingBreadcrumbsComponent {

  @Input() items: Array<any> = [];

  constructor() {
  }  
}
