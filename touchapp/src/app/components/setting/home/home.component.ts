import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';

@Component({
    templateUrl: './home.component.html',
    styleUrls: ['./home.component.scss']
})
export class SettingHomeComponent {

    @Input() items: Array<any> = [];

    constructor(private router: Router) {
    }

    onGoHome(){
        this.router.navigate(['/']);
    }

    onGoUsers() {
        this.router.navigate(['/setting/users']);
    }
}
