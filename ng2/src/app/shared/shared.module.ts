import { NgModule } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { CommonModule } from '@angular/common';

import { AuthHttp } from './providers/auth_http.provider';

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
    AuthHttp,
    Title
  ]
})
export class SharedModule { }