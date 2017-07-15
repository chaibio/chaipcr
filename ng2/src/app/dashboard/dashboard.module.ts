import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { DashboardRoutingModule } from './dashboard.routing.module';
import { DashboardComponent } from './dashboard.component';
import { HomeComponent } from './home/home.component';

@NgModule({
  imports: [
    DashboardRoutingModule,
    SharedModule,
  ],
  declarations: [
    DashboardComponent,
    HomeComponent,
  ],
})

export class DashboardModule { }