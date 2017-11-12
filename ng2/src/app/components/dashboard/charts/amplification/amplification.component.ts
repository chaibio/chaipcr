import { Component } from '@angular/core';
import { ExperimentService } from '../../../../services/experiment/experiment.service';

//import 'rxjs/operator/add/takeUntil';

@Component({
  templateUrl: './amplification.component.html',
  styleUrls: ['./amplification.component.scss']
})

export class AmplificationComponent {

  constructor(private expService: ExperimentService) {
    
  }

}
