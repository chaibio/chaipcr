import { NgModule } from '@angular/core';

import { SharedModule } from '../shared/shared.module';
import { DashboardRoutingModule } from './dashboard.routing.module';
import { DashboardAuthGuard } from './dashboard.auth-guard';
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
  providers: [
    DashboardAuthGuard,
  ]
})

export class DashboardModule { }