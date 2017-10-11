import {
  Component,
  ElementRef,
  OnChanges,
  OnDestroy,
  Input,
} from '@angular/core';

import { Experiment } from '../../models/experiment.model';
import { ExperimentService } from '../../services/experiment/experiment.service';
import { StatusService } from '../../services/status/status.service';
import { StatusData } from '../../models/status.model';

import 'rxjs/add/operator/takeUntil';
import { Subject } from 'rxjs/Subject';

@Component({
  selector: '[chai-header-status]',
  templateUrl: './header-status.component.html',
  styleUrls: ['./header-status.component.scss']
})

export class HeaderStatusComponent implements OnChanges, OnDestroy {

  public experiment: Experiment;
  public state: string;
  public statusData: StatusData;
  private ngUnsubscribe: Subject<void> = new Subject<void>(); // = new Subject(); in Typescript 2.2-2.4

  constructor(private el: ElementRef, private expService: ExperimentService, private statusService: StatusService) {
    statusService.$data
      .takeUntil(this.ngUnsubscribe)
      .subscribe((statusData: StatusData) => {
        this.extraceStatusData(statusData);
      })
  }

  @Input('experiment-id') expId: number;

  ngOnChanges() {
    if (this.expId) {
      this.expService.getExperiment(+this.expId).subscribe((exp: Experiment) => {
        this.experiment = exp;
      })
    }
  }
//https://stackoverflow.com/questions/38008334/angular-rxjs-when-should-i-unsubscribe-from-subscription
  ngOnDestroy() {
    this.ngUnsubscribe.next();
    this.ngUnsubscribe.complete();
  }

  public isCurrentExperiment(): boolean {
    if (this.statusData && this.experiment) {
      return this.statusData.experiment_controller.experiment.id === this.experiment.id;
    } else {
      return false;
    }
  }

  private extraceStatusData (d: StatusData) {
    this.statusData = d;
    this.state = d.experiment_controller.machine.state;
  }

}
