import { Component, Input, OnInit, OnDestroy } from '@angular/core';

@Component({
  selector: 'setting-breadcrumbs',
  templateUrl: './breadcrumbs.component.html',
  styleUrls: ['./breadcrumbs.component.scss']
})
export class SettingBreadcrumbsComponent{

  @Input() items: Array<any> = [];

  constructor() {}
}
