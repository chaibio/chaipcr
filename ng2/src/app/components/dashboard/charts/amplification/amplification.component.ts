import {
  Component,
  OnInit,
  OnDestroy
} from '@angular/core';

import {
  ActivatedRoute
} from '@angular/router';

import { ExperimentService } from '../../../../services/experiment/experiment.service';

//import 'rxjs/operator/add/takeUntil';

@Component({
  templateUrl: './amplification.component.html',
  styleUrls: ['./amplification.component.scss']
})

export class AmplificationComponent implements OnInit, OnDestroy{

  interval: any;
  routeParamSub: any;

  constructor(
    private expService: ExperimentService,
    private route: ActivatedRoute
  ) {

  }

  ngOnInit() {
    this.routeParamSub = this.route.params.subscribe(params => {
      this.interval = setInterval(() => {
        this.expService.getAmplificationData(+params['id']).subscribe();
      }, 1000);
    })
  }

  ngOnDestroy() {
    clearInterval(this.interval);
    this.routeParamSub.unsubscribe();
  }

}
