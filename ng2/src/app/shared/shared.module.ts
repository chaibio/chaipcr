import { NgModule } from '@angular/core';
import { BrowserModule, Title }  from '@angular/platform-browser';

import { AuthHttp } from './providers/auth_http.provider';

@NgModule({
  declarations: [
  ],
  imports: [
  ],
  exports: [
  ],
  providers: [
    AuthHttp,
    Title
  ]
})
export class SharedModule { }