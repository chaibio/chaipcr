import { Component, OnInit } from '@angular/core'

import {
  ExperimentService,
  ExperimentListItem
} from '../../../shared'

@Component({
  selector: 'experiment-list',
  templateUrl: './experiment-list.component.html',
  styleUrls: ['./experiment-list.component.scss']
})
export class ExperimentListComponent implements OnInit {

  experiments: ExperimentListItem[]

  constructor (private expService: ExperimentService) {}

  ngOnInit() {
    this.expService.getExperiments().subscribe(experiments => {
      this.experiments = experiments
    })
  }

}