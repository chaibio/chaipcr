import { Component } from '@angular/core';

import { Title } from '@angular/platform-browser'

@Component({
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent {

  constructor(private title: Title) {
    title.setTitle('ChaiPCR | Home')
  }

}
