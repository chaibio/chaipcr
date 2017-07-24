import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { DashboardRoutingModule } from './dashboard.routing.module';
import { DashboardComponent } from './dashboard.component';
import { HomeModule } from './home/home.module'

@NgModule({
  imports: [
    DashboardRoutingModule,
    SharedModule,
    HomeModule,
  ],
  declarations: [
    DashboardComponent,
  ],
})

export class DashboardModule { }