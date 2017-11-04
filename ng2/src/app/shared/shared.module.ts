import { NgModule } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { RouterModule } from '@angular/router';
import {
  CommonModule,
  APP_BASE_HREF
} from '@angular/common';

import { BaseHttp } from './services/base_http/base_http.service';
import { AuthHttp } from './services/auth_http/auth_http.service';
import { SessionService } from './services/session/session.service';
import { ExperimentService } from './services/experiment/experiment.service';
import { WindowRef } from './services/windowref/windowref.service';

import { LogoutDirective } from './directives/logout/logout.directive';
import { FullHeightDirective } from './directives/full-height/full-height.directive';
import { HeaderStatusComponent } from './directives/header-status/header-status.component';
import { HrMinSecPipe } from './pipes/hr-min-secs/hr-min-secs.pipe';

@NgModule({
  declarations: [
    LogoutDirective,
    FullHeightDirective,
    HeaderStatusComponent,
    HrMinSecPipe
  ],
  imports: [
    FormsModule,
    HttpModule,
    CommonModule,
  ],
  exports: [
    RouterModule,
    FormsModule,
    HttpModule,
    CommonModule,
    LogoutDirective,
    FullHeightDirective,
    HeaderStatusComponent,
    HrMinSecPipe
  ],
  providers: [
    Title,
    SessionService,
    ExperimentService,
    WindowRef,
    AuthHttp,
    BaseHttp,
    { provide: APP_BASE_HREF, useValue: '/' },
  ]
})

export class SharedModule { }
