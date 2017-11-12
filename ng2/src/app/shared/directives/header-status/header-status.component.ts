import {
  Component,
  ElementRef,
  OnChanges,
  OnDestroy,
  Input,
} from '@angular/core';
import { DomSanitizer } from '@angular/platform-browser';
import ngStyles from 'ng-style'
import { Router } from '@angular/router';
import { Experiment } from '../../models/experiment.model';
import { ExperimentService } from '../../../services/experiment/experiment.service';
import { StatusService } from '../../../services/status/status.service';
import { StatusData } from '../../models/status.model';

import 'rxjs/add/operator/takeUntil';
import { Subject } from 'rxjs/Subject';
import { Subscription } from 'rxjs/Subscription';

@Component({
  selector: '[chai-header-status]',
  templateUrl: './header-status.component.html',
  styleUrls: ['./header-status.component.scss']
})

export class HeaderStatusComponent implements OnChanges, OnDestroy {

  public experiment: Experiment;
  public state: string;
  public statusData: StatusData;
  public analyzed = false;
  public remainingTime: number;
  private background: string;
  private ngUnsubscribe: Subject<void> = new Subject<void>(); // = new Subject(); in Typescript 2.2-2.4
  private expCompleteSub: Subscription;
  private oldState: string;

  constructor(private el: ElementRef, private expService: ExperimentService, private statusService: StatusService, private router: Router, private sanitizer: DomSanitizer) {
    statusService.$data
      .takeUntil(this.ngUnsubscribe)
      .subscribe((statusData: StatusData) => {
        this.extraceStatusData(statusData);
      })

    this.expCompleteSub = this.expService.$updates.subscribe((evt) => {
      if(evt === `experiment:completed:${this.expId}`) {
        this.analyzed = true;
        this.fetchExperiment()
      }
    });

  }

  @Input('experiment-id') expId: number;

  ngOnChanges() {
    this.fetchExperiment()
  }
  //https://stackoverflow.com/questions/38008334/angular-rxjs-when-should-i-unsubscribe-from-subscription
  ngOnDestroy() {
    this.ngUnsubscribe.next();
    this.ngUnsubscribe.complete();
  }

  public startExperiment() {
    this.expService.startExperiment(+this.expId).subscribe(() => {
      this.fetchExperiment()
      this.router.navigate(['/charts', 'exp', +this.expId, 'amplification'])
    })
  }

  public isCurrentExperiment(): boolean {
    if (this.statusData && this.expId) {
      return this.statusData.experiment_controller.experiment.id === +this.expId;
    } else {
      return false;
    }
  }

  private fetchExperiment() {
    if (this.expId) {
      this.expService.getExperiment(+this.expId).subscribe((exp: Experiment) => {
        this.experiment = exp;
        if (exp.started_at && !this.analyzed) {
          this.expService.getAmplificationData(exp.id).subscribe()
        }
      })
    }
  }

  private extraceStatusData (d: StatusData) {
    this.statusData = d;
    this.state = d.experiment_controller.machine.state;
    this.remainingTime = this.statusService.timeRemaining();
    //if(this.state === 'running' && this.isCurrentExperiment()) {

    //}
    if (this.oldState && this.oldState !== 'idle' && this.state === 'idle') {
      this.fetchExperiment()
    }
    this.oldState = this.state
  }

  public getBackgroundStyle () {
    if (!this.state || !this.experiment) return this.sanitizer.bypassSecurityTrustStyle('')
    let bg = ''
    let p = this.statusService.timePercentage() * 100
    if (this.state !== 'idle' && this.isCurrentExperiment())
      bg = `linear-gradient(left,  #64b027 0%,#c6e35f ${p || 0}%,#0c2c03 ${p || 0}%,#0c2c03 100%)`
    if (this.isCurrentExperiment() && !this.analyzed && this.experiment.completed_at)
      bg = `linear-gradient(left,  #64b027 0%,#c6e35f ${100}%,#0c2c03 ${100}%,#0c2c03 100%)`
    if (this.isCurrentExperiment() && this.analyzed && this.experiment.completed_at && this.state !== 'idle')
      bg = `linear-gradient(left,  #64b027 0%,#c6e35f ${100}%,#0c2c03 ${100}%,#0c2c03 100%)`

    let s = bg === '' ? bg : {
      background: bg
    }
    let style = ngStyles(s)
    return this.sanitizer.bypassSecurityTrustStyle(style)

  }

}
