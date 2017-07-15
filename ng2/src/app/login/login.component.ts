import { Component, OnInit } from '@angular/core';
import { Http } from '@angular/http';
import { Title }  from '@angular/platform-browser';

@Component({
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})

export class LoginComponent implements OnInit {

  deviceInfo: any;
  deviceInfoError: any;
  loginError: any;
  credentials: any;

  constructor (private http: Http, private titleService: Title) {
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

  doSubmit () {
    this.http.post('/login', this.credentials).subscribe((res) => {
      console.log(res.json());
    }, (res) => {
      this.loginError = true;
    })
  }

}

