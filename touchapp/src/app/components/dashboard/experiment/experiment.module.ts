import { NgModule } from '@angular/core'

import { ExperimentComponent } from './experiment.component'

import { SharedModule } from '../../../shared/shared.module'

const components = [
  ExperimentComponent,
]

@NgModule({
  imports: [ SharedModule ],
  declarations: components,
  exports: components
})

export class ExperimentModule {}
