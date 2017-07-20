import { NgModule } from '@angular/core'

import { HomeComponent } from './home.component'
import { ExperimentListComponent } from './experiment-list/experiment-list.component'

const components = [
  HomeComponent,
  ExperimentListComponent
]

@NgModule({
  declarations: components,
  exports: components
})

export class HomeModule {}