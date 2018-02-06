import {
  Injectable
} from '@angular/core';

@Injectable()
export class ChartConfigService {

  private _colors: Array<string>;

  constructor() {
    this._colors = [
      '#04A0D9',
      '#1578BE',
      '#2455A8',
      '#3B2F90',
      '#73258C',
      '#B01C8B',
      '#FA1284',
      '#FF004E',
      '#EA244E',
      '#FA3C00',
      '#EF632A',
      '#F5AF13',
      '#FBDE26',
      '#B6D333',
      '#67BC42',
      '#13A350'
    ];
  }

  getColors() {
    return this._colors;
  }

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
