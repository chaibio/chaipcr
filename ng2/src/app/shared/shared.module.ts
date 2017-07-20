import { NgModule } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { CommonModule, APP_BASE_HREF } from '@angular/common';

import { AuthHttp } from './services/auth_http/auth_http.service';
import { SessionService } from './services/session/session.service';
import { LogoutComponent } from './components/logout/logout.component'

@NgModule({
  declarations: [
    LogoutComponent
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
    LogoutComponent,
  ],
  providers: [
    Title,
    AuthHttp,
    SessionService,
    {provide: APP_BASE_HREF, useValue: '/'}
  ]
})
export class SharedModule { }