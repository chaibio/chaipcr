import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { NgbModule } from '@ng-bootstrap/ng-bootstrap';

import { SharedModule } from './shared/shared.module';
import { AppRoutesModule } from './app.routing.module';
import { DashboardModule } from './components/dashboard/dashboard.module';
import { SettingModule } from './components/setting/setting.module';

import { AppComponent } from './app.component';

import { BaseHttp } from './services/base_http/base_http.service';
import { AuthHttp } from './services/auth_http/auth_http.service';
import { SessionService } from './services/session/session.service';
import { ChartConfigService } from './services/chart-config/base-chart-config.service';
import { AmplificationConfigService } from './services/chart-config/amplification-chart-config.service';
import { StatusService } from './services/status/status.service';
import { ExperimentService } from './services/experiment/experiment.service';
import { WindowRef } from './services/windowref/windowref.service';
import { BreadCrumbsService } from './services/breadcrumbs.service';
import { CookiesService } from './services/cookie.service';

@NgModule({
  declarations: [
    AppComponent,
  ],
  imports: [
    BrowserModule,
    NgbModule.forRoot(),
    SharedModule,
    AppRoutesModule,
    DashboardModule,
    SettingModule,
  ],
  providers: [
    // declare global singletone services here
    StatusService,
    ExperimentService,
    WindowRef,
    BaseHttp,
    AuthHttp,
    SessionService,
    ChartConfigService,
    AmplificationConfigService,
    BreadCrumbsService,
    CookiesService,
  ],
  exports: [
    DashboardModule,
    SettingModule
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
