import { NgModule } from '@angular/core';

import { SharedModule } from '../../../shared/shared.module';
import { ChartsComponent } from './charts.component';
import { AmplificationComponent } from './amplification/amplification.component';

const components = [ 
  ChartsComponent,
  AmplificationComponent,
];

@NgModule({
  imports: [
    SharedModule
  ],
  declarations: components,
  exports: components
})

export class ChartsModule {}
