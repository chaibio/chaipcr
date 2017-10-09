import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { ChartsRoutingModule } from './charts.routing.module';
import { ChartsComponent } from './charts.component';
import { AmplificationComponent } from './amplification/amplification.component';

const components = [ 
  ChartsComponent,
  AmplificationComponent
];

@NgModule({
  imports: [
    ChartsRoutingModule,
    SharedModule
  ],
  declarations: components,
  exports: components
})

export class ChartsModule {}
