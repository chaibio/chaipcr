import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { DashboardRoutingModule } from './dashboard.routing.module';
import { DashboardComponent } from './dashboard.component';
import { HomeModule } from './home/home.module'
// import { HomeComponent } from './home/home.component';
// import { ExperimentListComponent } from './home/experiment-list/experiment-list.component';

@NgModule({
  imports: [
    DashboardRoutingModule,
    SharedModule,
    HomeModule,
  ],
  declarations: [
    DashboardComponent,
    // HomeComponent,
    // ExperimentListComponent,
  ],
  // exports: [ExperimentListComponent]
})

export class DashboardModule { }