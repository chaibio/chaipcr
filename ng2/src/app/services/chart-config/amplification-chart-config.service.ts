import {
  Injectable
} from '@angular/core';

import { ChartConfigService } from './base-chart-config.service';

@Injectable()
export class AmplificationConfigService extends ChartConfigService {

  getConfig() {
    return {
      axes: {
        x: {
          min: 1,
          key: 'cycle_num',
          ticks: 8,
          label: 'CYCLE NUMBER'
        },
        y: {
          unit: 'k',
          label: 'RELATIVE FLUORESCENCE UNITS',
          ticks: 10,
          tickFormat: (y) => {
            return Math.round((y / 1000) * 10) / 10;
          },
          scale: 'linear'
        }
      },
      box: {
        label: {
          x: 'Cycle',
          y: 'RFU'
        }
      },
      series: []
    };
  }

}
