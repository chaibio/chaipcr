import {
  Component, 
  ElementRef,
  OnInit,
  Input,
} from '@angular/core';

import { Experiment } from '../../models/experiment.model';
import { ExperimentService } from '../../services/experiment/experiment.service';
import { StatusService } from '../../services/status/status.service';
import { StatusData } from '../../models/status.model';

@Component({
  selector: '[chai-header-status]',
  templateUrl: './header-status.component.html',
  styleUrls: ['./header-status.component.scss']
})

export class HeaderStatusComponent implements OnInit {

  public experiment: Experiment;
  public state: string;
  public statusData: StatusData;

  constructor(private el: ElementRef, private expService: ExperimentService, private statusService: StatusService) {
    statusService.$data.subscribe((statusData: StatusData) => {
      this.extraceStatusData(statusData);
    })
  }

  @Input('experiment-id') expId: number;

  ngOnInit() {
    this.expService.getExperiment(+this.expId).subscribe((exp: Experiment) => {
      this.experiment = exp; 
    })
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
