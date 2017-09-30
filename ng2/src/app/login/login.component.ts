import { Component, OnInit } from '@angular/core';
import { Http } from '@angular/http';
import { Title } from '@angular/platform-browser';
import { Router } from '@angular/router';

import { BaseHttp } from '../shared/services/base_http/base_http.service';
import { SessionService } from '../shared/services/session/session.service';
import { LoginFormData } from '../shared/models/login-form-data.model'

@Component({
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})

export class LoginComponent implements OnInit {

  deviceInfo: any;
  deviceInfoError: any;
  loginError: any;
  credentials: LoginFormData;

  constructor(
    private http: BaseHttp,
    private titleService: Title,
    private sessionService: SessionService,
    private router: Router
  ) {
    titleService.setTitle('ChaiPCR | Login');
  }

  ngOnInit() {

    this.deviceInfo = {
      serial_number: null,
      software: {
        version: null
      }
    };

    this.credentials = {
      email: null,
      password: null
    }

    this.http.get('/device').subscribe((res) => {
      this.deviceInfo = res.json();
    }, (res) => {
      this.deviceInfoError = res.json();
    })

  }

  doSubmit() {
    this.sessionService.login(this.credentials).subscribe((res) => {
      this.router.navigate(['/'])
    }, (error: any) => {
      this.loginError = error;
    })
  }

}

