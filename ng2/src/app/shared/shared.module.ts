import { NgModule } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import {
  CommonModule,
  APP_BASE_HREF
} from '@angular/common';

import { AuthHttp } from './services/auth_http/auth_http.service';
import { SessionService } from './services/session/session.service';
import { ExperimentService } from './services/experiment/experiment.service'
import { WindowRef } from './services/windowref/windowref.service'
import { LogoutDirective } from './directives/logout/logout.directive'

@NgModule({
  declarations: [
    LogoutDirective
  ],
  imports: [
    FormsModule,
    HttpModule,
    CommonModule,
  ],
  exports: [
    FormsModule,
    HttpModule,
    CommonModule,
    LogoutDirective,
  ],
  providers: [
    Title,
    AuthHttp,
    SessionService,
    ExperimentService,
    WindowRef,
    { provide: APP_BASE_HREF, useValue: '/' },
  ]
})
export class SharedModule { }