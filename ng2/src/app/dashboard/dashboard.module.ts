import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { DashboardRoutingModule } from './dashboard.routing.module';
import { DashboardComponent } from './dashboard.component';
import { HomeModule } from './home/home.module'
import { ChartsModule } from './charts/charts.module';

@NgModule({
  imports: [
    DashboardRoutingModule,
    SharedModule,
    HomeModule,
    ChartsModule,
  ],
  declarations: [
    DashboardComponent,
  ],
})

export class DashboardModule { }
