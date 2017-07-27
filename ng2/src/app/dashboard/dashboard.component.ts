import { Component } from '@angular/core';
import { StatusService } from '../shared/services/status/status.service'

@Component({
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent {

  constructor(statusService: StatusService) {
    statusService.startSync();
  }

}
