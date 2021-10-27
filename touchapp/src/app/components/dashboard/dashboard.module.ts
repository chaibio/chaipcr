import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';

import { SharedModule } from '../../shared/shared.module';
import { DashboardAuthGuard } from './dashboard.auth-guard';
import { DashboardComponent } from './dashboard.component';
import { HomeModule } from './home/home.module'
import { ChartsModule } from './charts/charts.module';

@NgModule({
  imports: [
    RouterModule,
    SharedModule,
    HomeModule,
    ChartsModule,
  ],
  declarations: [
    DashboardComponent,
  ],
  exports: [
    HomeModule,
    DashboardComponent
  ],
  providers: [
    DashboardAuthGuard,
  ]
})

export class DashboardModule { }
