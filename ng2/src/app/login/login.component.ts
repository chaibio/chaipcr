import { Component } from '@angular/core';
import { Http } from '@angular/http';

@Component({
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {

  constructor (http: Http) {}

  login () {
    console.log('Login..!!!')
  }

}
