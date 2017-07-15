import { Component, OnInit } from '@angular/core';
import { Http } from '@angular/http';
import { Title }  from '@angular/platform-browser';

@Component({
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})

export class LoginComponent implements OnInit {

  deviceInfo: {
    serial_number: ''
    software: {
      version: ''
    }
  };
  deviceInfoError: any;
  loginError: any;

  constructor (private http: Http, private titleService: Title) {
    titleService.setTitle('ChaiPCR | Login');
  }

  ngOnInit() {
    this.http.get('/device').subscribe((res) => {
      this.deviceInfo = res.json();
      console.log(this.deviceInfo);
    }, (res) => {
      this.deviceInfoError = res.json();
    })
  }

  login () {
    console.log('Login..!!!')
  }

}

