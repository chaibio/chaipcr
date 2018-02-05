import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { SharedModule } from './shared/shared.module';
import { AppRoutesModule } from './app.routing.module';
import { DashboardModule } from './components/dashboard/dashboard.module';

import { AppComponent } from './app.component';

import { StatusService } from './services/status/status.service';
import { ExperimentService } from './services/experiment/experiment.service';
import { WindowRef } from './services/windowref/windowref.service';

@NgModule({
  declarations: [
    AppComponent,
  ],
  imports: [
    BrowserModule,
    SharedModule,
    AppRoutesModule,
    DashboardModule,
  ],
  providers: [
    // declare global singletone services here
    StatusService,
    ExperimentService,
    WindowRef
  ],
  exports: [
    DashboardModule
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
