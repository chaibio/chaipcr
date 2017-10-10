import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

@Component({
  styleUrls: ['./charts.component.scss'],
  templateUrl: './charts.component.html'
})

export class ChartsComponent {

  public experimentId: number;

  constructor(private route: ActivatedRoute) {
    route.params.subscribe((params) => {
      this.experimentId = +params['id'];
    })
  }

}
