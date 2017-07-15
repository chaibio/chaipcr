import { NgModule } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { CommonModule } from '@angular/common';

import { AuthHttp } from './services/auth_http.service';
import { SessionService } from './services/session.service';

@NgModule({
  declarations: [
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
  ],
  providers: [
    Title,
    AuthHttp,
    SessionService
  ]
})
export class SharedModule { }