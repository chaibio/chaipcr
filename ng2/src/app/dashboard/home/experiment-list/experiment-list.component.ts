import { Component, OnInit } from '@angular/core'

import {
  ExperimentService,
  ExperimentList
} from '../../../shared'

@Component({
  selector: 'experiment-list',
  templateUrl: './experiment-list.component.html',
  styleUrls: ['./experiment-list.component.scss']
})
export class ExperimentListComponent implements OnInit {

  experiments: ExperimentListItem[]
  editing: boolean

  constructor (private expService: ExperimentService) {}

  ngOnInit() {
    this.expService.getExperiments().subscribe((experiments: ExperimentList[]) => {
      this.experiments = experiments.map(exp => {
        return {
          model: exp,
          open: false
        }
      })
    })
  }

  toggleEditing() {
    this.editing = !this.editing
  }

  editList(exp: ExperimentListItem) {
    exp.open = true;
  }

}

export interface ExperimentListItem {
  model: ExperimentList,
  open: boolean
}