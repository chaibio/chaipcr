import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { Title } from '@angular/platform-browser'

@Component({
	templateUrl: './home.component.html',
	styleUrls: ['./home.component.scss']
})
export class HomeComponent {

	constructor(private title: Title, private router: Router) {
		title.setTitle('ChaiPCR | Home')
	}

	onSetting(){
		this.router.navigate(['/setting']);
	}

}
