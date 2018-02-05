import {
  Component,
  Input,
  Output,
  EventEmitter,
  OnChanges,
  SimpleChanges,
  OnInit,
  ElementRef,
  HostListener
} from '@angular/core';

import { WellButtonI } from '../../models/well-button.model';
import { ChartConfigService } from '../../services/chart-config/base-chart-config.service';
import { WindowRef } from '../../../services/windowref/windowref.service';

@Component({
  selector: '[chai-well-buttons]',
  templateUrl: './well-buttons.component.html',
  styleUrls: ['./well-buttons.component.scss']
})
export class WellButtonsComponent implements OnChanges, OnInit {

  readonly ROW_HEADER_WIDTH = 30;
  readonly ACTIVE_BORDER_WIDTH = 2;
  readonly NUM_WELLS = 16;

  private _wells: any;
  private rows: Array<any>;
  private cols: Array<any>;
  private isCmdKeyHeld = false;
  private isDragging = false;
  private dragStartingPoint: {type: string, index:number};

  @Input() colorby: string;
  @Output() onSelectWells = new EventEmitter<Array<WellButtonI>>();
  @Input()
  set wells(w) {
    if(!w) {
      this._wells = {};
      this.initWells();
    }
  }
  @HostListener('document:keypress', ['$event'])
  onKeyDown(e) {
    console.log(e)
  }

  constructor(
    private config: ChartConfigService,
    private el: ElementRef,
    private wref: WindowRef
  ) {
    this._wells = {};
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

  isCtrlKeyHeld(e) {
    return e.ctrlKey || this.isCmdKeyHeld
  }

  getWidth():number {
    return this.el.nativeElement.parentElement.offsetWidth
  }

  getCellWidth() {
    return (this.getWidth() - this.ROW_HEADER_WIDTH) / this.cols.length
  }

  getWellIndex(row, col) {
    return (row.index * this.cols.length) + col.index;
  }

  getWell(row, col) {
    let i = this.getWellIndex(row, col)
    let well = this._wells[`well_${i}`]
    return well
  }

  getWellContainerStyle(row, col, well, i) {
    let style: any = {};
    if (well.active)
      style.width = `${this.getCellWidth() + this.ACTIVE_BORDER_WIDTH * 4}px`;
    return style;
  }

  getStyleForWellBar(row, col, config, i) {
    return {
      'background-color' : config.color,
      'opacity' : config.selected ? 1 : 0.25
    }
  }

  ngOnInit() {
    this.initWells();
  }

  dragStart(e, t: string, i: number) {
    this.isDragging = true;
    this.dragStartingPoint = {
      type: t,
      index: i
    }
  }

  dragged(e, type, index) {
    if (!this.isDragging) return;
    if (type === this.dragStartingPoint.type && index === this.dragStartingPoint.index) return;
    switch(this.dragStartingPoint.type) {
      case 'column': {
        if (type === 'well')
          index = index >= this.cols.length ? index - this.cols.length : index
        let max = Math.max.apply(Math, [index, this.dragStartingPoint.index])
        let min = max === index ? this.dragStartingPoint.index : index
        this.cols.forEach((col) => {
          col.selected = col.index >= min && col.index <= max
          this.rows.forEach((row) => {
            let well = this._wells[`well_${row.index * this.cols.length + col.index}`]
            if(!(this.isCtrlKeyHeld(e) && well.selected))
              well.selected = col.selected
          })
        })
        break
      } case 'row': {
        if(type === 'well')
          index = index >= 8? 1 : 0;
        let max = Math.max.apply(Math, [index, this.dragStartingPoint.index])
        let min = max === index? this.dragStartingPoint.index : index
        this.rows.forEach((row) => {
          row.selected = row.index >= min && row.index <= max
          this.cols.forEach((col) => {
            let well = this._wells[`well_${row.index * this.cols.length + col.index}`]
            if(!(this.isCtrlKeyHeld(e) && well.selected))
              well.selected = row.selected
          })
        })
        break;
      } case 'well': {
        if(type === 'well') {
          let row1 = Math.floor(this.dragStartingPoint.index / this.cols.length)
          let col1 = this.dragStartingPoint.index - row1 * this.cols.length
          let row2 = Math.floor(index / this.cols.length)
          let col2 = index - row2 * this.cols.length
          let max_row = Math.max.apply(Math, [row1, row2])
          let min_row = max_row === row1? row2 : row1
          let max_col = Math.max.apply(Math, [col1, col2])
          let min_col = max_col === col1? col2: col1
          this.rows.forEach((row) => {
            this.cols.forEach((col) => {
              let selected = (row.index >= min_row && row.index <= max_row) && (col.index >= min_col && col.index <= max_col)
              let well = this._wells[`well_${row.index * this.cols.length + col.index}`]
              if(!(this.isCtrlKeyHeld(e) && well.selected))
                well.selected = selected
            })
          })
        }
      }
    }
  }

  dragStop(e, t, i) {
    this.isDragging = false;
    this.cols.forEach((col) => {
      col.selected = false
    })
    this.rows.forEach((row) => {
      row.selected = false
    })
    if(t === 'well' && i === this.dragStartingPoint.index) {
      if (!this.isCtrlKeyHeld(e)) {
        this.rows.forEach((r) => {
          this.cols.forEach((c) => {
            this._wells[`well_${r.index * this.cols.length + c.index}`].selected = false
          })
        })
      }
      let well = this._wells[`well_${i}`]
      well.selected = this.isCtrlKeyHeld(e) ? !well.selected : true
    }
  }

  private initWells() {
    for (let i = 0; i < this.NUM_WELLS; i ++) {
      this._wells[`well_${i}`] = {
        active: true,
        selected: true,
        color: this.colorby === 'wells' ? this.config.getColors()[i] : '#75278E',
        cts: [1, 2]
      }
    }
    this.onSelectWells.emit(this._wells);
  }

  ngOnChanges(changes: SimpleChanges):void {
    if (changes.colorby.previousValue !== changes.colorby.currentValue) {
      for (let i = 0; i < this.NUM_WELLS; i ++) {
        this._wells[`well_${i}`].color = this.colorby === 'well' ? this.config.getColors()[i] : '#75278E'
      }
      console.log('colors changed!')
    }
  }

}
