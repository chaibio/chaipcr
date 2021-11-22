import { Component, Input, OnInit, OnDestroy } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { StatusService } from '../../../services/status/status.service'
import { ExperimentService } from '../../../services/experiment/experiment.service'
import { Experiment } from '../../../shared/models/experiment.model'
import { StatusData } from '../../../shared/models/status.model'

@Component({
    templateUrl: './experiment.component.html',
    styleUrls: ['./experiment.component.scss']
})
export class ExperimentComponent implements OnDestroy, OnInit {

    public isConfirmStop: boolean = false
    public experimentId: number = 0
    public experiment: Experiment = null;
    public machineStatus: StatusData = null;
    public timeRemaining: number = 0;

    constructor(
        private router: Router,
        private activatedRoute: ActivatedRoute,
        private statusService: StatusService,
        private experimentService: ExperimentService
    ) {
        this.activatedRoute.params.subscribe(params => {
            this.experimentId = parseInt(params['id'])
            this.experimentService.getExperiment(this.experimentId).subscribe(exp => {
                this.experiment = exp;
            })
        })
    }

    ngOnInit() {
        this.statusService.$data.subscribe(data => {
            this.processStatus(data);
        })
    }

    onStopExp(){
        if(!this.isConfirmStop){
            this.isConfirmStop = true
        } else {
            this.experimentService.stopExperiment(this.experimentId).subscribe(() => {
                this.router.navigate(['/']);
            })
        }
    }

    getTimeRemaining(data) {
        let exp, time;
        if (!data) {
          return 0;
        }
        if (!data.experiment_controller) {
          return 0;
        }
        if (data.experiment_controller.machine.state !== 'idle') {
          exp = data.experiment_controller.experiment;
          time = ((exp.estimated_duration*1) + (exp.paused_duration*1)) - (exp.run_duration*1);
          return time < 0 ? 0 : time;
        } else {
          return 0;
        }
    };

    processStatus(data){
        this.machineStatus = data;
        const state = data.experiment_controller.machine.state;
        this.timeRemaining = this.getTimeRemaining(data);
        if(state == 'idle'){
            this.router.navigate([`/`]);
        }
    }

    ngOnDestroy() {}
}
