import {
  Directive,
  ElementRef,
  Input,
  OnChanges
} from '@angular/core';

import * as d3 from 'd3';
import { WindowRef } from '../../../services/windowref/windowref.service';
import { BaseChartDirective } from '../base-chart/base-chart.component';

@Directive({
  selector: '[chai-amplification-chart]'
})
export class AmplificationChartDirective extends BaseChartDirective {
  
  constructor(protected el: ElementRef, protected wref: WindowRef) {
    super(el, wref)
  }

}
