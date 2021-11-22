import {
  Component,
  OnInit,
  HostListener,
  ElementRef
} from '@angular/core'

import { ExperimentService } from '../../../../services/experiment/experiment.service'
import { ExperimentList } from '../../../../shared/models/experiment-list.model'
import { StatusService } from '../../../../services/status/status.service'

const ESCAPE_KEYCODE = 27;

@Component({
  selector: 'experiment-list',
  templateUrl: './experiment-list.component.html',
  styleUrls: ['./experiment-list.component.scss']
})
export class ExperimentListComponent implements OnInit {

  experiments: ExperimentListItem[]
  editing: boolean
  machine_state: string = ''
  current_experiment_id: number = 0;

  constructor(
    private expService: ExperimentService,
    private el: ElementRef,
    private statusService: StatusService
  ) {

  }

  @HostListener('document:keydown', ['$event']) onKeydownHandler(event: KeyboardEvent) {
    let code = +event.code || event.keyCode
    if (code === ESCAPE_KEYCODE) {
      this.editing = false
      this.experiments.forEach(exp => {
        exp.confirmDelete = false
      })
    }
  }

  ngOnInit() {
    this.expService.getExperiments().subscribe((experiments: ExperimentList[]) => {
      this.experiments = experiments.map(exp => {
        return {
          model: exp,
          confirmDelete: false,
          deleting: false,
        }
      })
    })

    this.statusService.$data.subscribe(data => {
      this.machine_state = data.experiment_controller.machine.state;
      this.current_experiment_id = (data.experiment_controller.experiment) ? data.experiment_controller.experiment.id : 0;
    })    
  }

  toggleEditing() {
    this.editing = !this.editing
  }

  confirmDelete(exp: ExperimentListItem, index: number) {
    exp.confirmDelete = true;
    let li: HTMLLIElement = this.el.nativeElement.querySelectorAll('li.exp-list-item')[index]
    let button: HTMLButtonElement = li.querySelector('button')
    setTimeout(() => {
      button.focus()
    }, 500)
  }

  focusOut(exp: ExperimentListItem) {
    exp.confirmDelete = false
  }

  deleteExperiment(exp: ExperimentListItem) {
    exp.deleting = true
    this.expService.deleteExperiment(exp.model.id).subscribe((res) => {
      let newExpList: ExperimentListItem[] = []
      this.experiments.forEach(experiment => {
        if (exp.model.id !== experiment.model.id) {
          newExpList.push(experiment)
        }
      })
      this.experiments = newExpList
    })
  }

  getExperimentLineItem(experiment){
    if(!experiment.started_at && experiment.time_valid){
      return `Created ${experiment.created_at}, #${experiment.id}`
    }

    if(!experiment.started_at && !experiment.time_valid){
      return `Created, #${experiment.id}`
    }

    if(experiment.started_at && experiment.completed_at && experiment.time_valid){
      return `Run ${experiment.started_at}, #${experiment.id}`
    }

    if(experiment.started_at && !experiment.completed_at && (experiment.id!=this.current_experiment_id || this.machine_state == 'idle')){
      return `Run ${experiment.started_at}, #${experiment.id}`
    }

    if(experiment.started_at && !experiment.completed_at && (experiment.id!=this.current_experiment_id || this.machine_state !== 'idle')){
      return `IN PROGRESS...`
    }
  }

}

export interface ExperimentListItem {
  model: ExperimentList,
  confirmDelete: boolean,
  deleting: boolean
}
