import {
  Component,
  OnInit,
  HostListener,
  ElementRef
} from '@angular/core'

import { ExperimentService } from '../../../../services/experiment/experiment.service'
import { ExperimentList } from '../../../../shared/models/experiment-list.model'

const ESCAPE_KEYCODE = 27;

@Component({
  selector: 'experiment-list',
  templateUrl: './experiment-list.component.html',
  styleUrls: ['./experiment-list.component.scss']
})
export class ExperimentListComponent implements OnInit {

  experiments: ExperimentListItem[]
  editing: boolean

  constructor(private expService: ExperimentService, private el: ElementRef) {

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

}

export interface ExperimentListItem {
  model: ExperimentList,
  confirmDelete: boolean,
  deleting: boolean
}
