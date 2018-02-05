import {
  Component,
  OnInit,
  OnDestroy
} from '@angular/core';

import {
  ActivatedRoute
} from '@angular/router';

import { WindowRef } from '../../../../services/windowref/windowref.service';
import { ExperimentService } from '../../../../services/experiment/experiment.service';
import { AmplificationConfigService } from '../../../../shared/services/chart-config/amplification-chart-config.service';

//import 'rxjs/operator/add/takeUntil';

@Component({
  templateUrl: './amplification.component.html',
  styleUrls: ['./amplification.component.scss']
})

export class AmplificationComponent implements OnInit, OnDestroy{

  colorBy: string; 
  config: any;
  retryInterval: any;
  retrying = false;
  retrySeconds: number;
  routeParamSub: any;
  experimentId: number;
  fetchError: null|string;
  fetchingAmpliData = false;
  ampliData: any;

  constructor(
    private expService: ExperimentService,
    private route: ActivatedRoute,
    private wref: WindowRef,
    private configService: AmplificationConfigService
  ) {
    this.config = configService.getConfig();
    this.colorBy = 'well';
  }

  ngOnInit() {
    this.routeParamSub = this.route.params.subscribe(params => {
      this.experimentId = +params.id;
      this.fetchFluorescenceData();
    })
  }

  refetch() {
    this.retrying = true;
    this.retrySeconds = 5;
    this.retryInterval = this.wref.nativeWindow().setInterval(() => {
      this.retrySeconds -= 1;
      if(this.retrySeconds === 0) {
        clearInterval(this.retryInterval);
        this.retrying = false;
        this.fetchError = null;
        this.fetchFluorescenceData();
      }
    }, 1000);
  }

  fetchFluorescenceData() {
    if(!this.retrying && !this.fetchingAmpliData) {
      this.fetchingAmpliData = true;
      this.expService.getAmplificationData(this.experimentId)
        .subscribe(data => {
          this.fetchingAmpliData = false;
          this.updateSeries(null);
          this.ampliData = data;
          this.refetch();
        }, error => {
          this.fetchingAmpliData = false;
          console.log(error);
          this.refetch();
        })
    }
  }

  updateSeries(buttons) {
    buttons = buttons || {}
    const subtraction_type = 'baseline';
    this.config.series = []
    let channel_count = 1
    let channel_end = 2
    let channel_start = 1
    for (let ch_i = channel_start; ch_i <= channel_end; ch_i++) {
      for(let i = 0; i <= 15; i ++) {
        //if buttons["well_#{i}"]?.selected
        this.config.series.push({
          dataset: `channel_${ch_i}`,
          x: 'cycle_num',
          y: `well_${i}_${subtraction_type}`,
          color: 'red',
          //cq: $scope.wellButtons["well_#{i}"]?.ct,
          well: i,
          channel: ch_i
        })
      }
    }

  }

  onWellsSelected(e, data) {
    console.log(e) 
    console.log(data)
  }

  ngOnDestroy() {
    clearInterval(this.retryInterval);
    this.routeParamSub.unsubscribe();
  }

}

