import { NgModule } from '@angular/core'

import { HomeComponent } from './home.component'
import { ExperimentListComponent } from './experiment-list/experiment-list.component'

import { SharedModule } from '../../../shared/shared.module'

const components = [
  HomeComponent,
  ExperimentListComponent,
]

@NgModule({
  imports: [ SharedModule ],
  declarations: components,
  exports: components
})

export class HomeModule {}
