import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';

@Component({
    templateUrl: './new-user.component.html',
    styleUrls: ['./new-user.component.scss']
})
export class NewUserComponent {

    constructor(private router: Router) {}

    onGoHome(){
        this.router.navigate(['/']);
    }
}
