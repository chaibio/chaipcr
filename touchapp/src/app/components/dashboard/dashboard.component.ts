import { 
  Component, 
  OnDestroy
} from '@angular/core';
import { StatusService } from '../../services/status/status.service'

@Component({
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnDestroy{

  constructor(private statusService: StatusService) {
    // statusService.startSync();
  }

  ngOnDestroy() {
    // this.statusService.stopSync()
  }

}
