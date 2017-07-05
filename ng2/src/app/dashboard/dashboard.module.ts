import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

// import { AuthModule } from './auth.module';
import { DashboardRoutingModule } from './dashboard.routing.module';
import { DashboardAuthGuard } from './dashboard.auth-guard';
import { DashboardComponent } from './dashboard.component';
import { HomeComponent } from './home/home.component';

@NgModule({
  imports: [
    CommonModule,
    DashboardRoutingModule,
    // AuthModule,
  ],
  declarations: [
    DashboardComponent,
    HomeComponent,
  ],
  exports: [
    DashboardComponent,
    HomeComponent,
  ],
  providers: [
    DashboardAuthGuard,
  ]
})

export class DashboardModule { }