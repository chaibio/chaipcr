import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnChanges,
  SimpleChanges,
  OnInit
} from '@angular/core';

import { WellButtonI } from '../../models/well-button.model';
import { AmplificationConfigService } from '../../services/chart-config/amplification-chart-config.service';

@Component({
  selector: '[chai-well-buttons]',
  templateUrl: './well-buttons.component.html'
})
export class WellButtonsComponent implements OnChanges, OnInit {

  private _wells: Array<WellButtonI>;
  private rows: Array<any>;
  private cols: Array<any>;

  @Input() wells: any;
  @Input() colorby: string;
  @Output() onSelectWells = new EventEmitter<Array<WellButtonI>>();
  //@Input()
  //set wells(w) {
  //  if(!w) {
  //    this._wells = [];
  //    this.initWells();
  //  }
  //}

  constructor(private config: AmplificationConfigService) {
    this._wells = [];
    this.cols = [];
    this.rows = [];
    for (let i = 0; i < 8; i ++) {
      this.cols.push({
        index: i,
        selected: false
      });
    }
    for (let i = 0; i < 2; i ++) {
      this.rows.push({
        index: i,
        selected: false
      });
    }
  }

  getCellWidth() {
    return 50;
  }

  ngOnInit() {
    this.initWells();
  }

  private initWells() {
    const numWells = 16
    for (let i = 0; i < numWells; i ++) {
      this._wells.push({
        active: true,
        selected: true,
        color: this.colorby === 'wells' ? this.config.COLORS[i] : 'green',
        cts: [1,2]
      });
    }
    //this.onSelectWells.emit(this._wells);
  }

  ngOnChanges(changes: SimpleChanges):void {

  }

}
