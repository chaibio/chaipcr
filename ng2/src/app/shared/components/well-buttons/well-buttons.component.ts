import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnChanges,
  SimpleChanges,
  OnInit,
  ElementRef
} from '@angular/core';

import { WellButtonI } from '../../models/well-button.model';
import { ChartConfigService } from '../../services/chart-config/base-chart-config.service';

@Component({
  selector: '[chai-well-buttons]',
  templateUrl: './well-buttons.component.html'
})
export class WellButtonsComponent implements OnChanges, OnInit {

  private _wells: Array<WellButtonI>;
  private rows: Array<any>;
  private cols: Array<any>;
  private row_header_width = 100;

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

  constructor(
    private config: ChartConfigService,
    private el: ElementRef
  ) {
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

  getWidth():number {
    return this.el.nativeElement.parentElement.offsetWidth
  }

  getCellWidth() {
    return (this.getWidth() - this.row_header_width) / this.cols.length
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
