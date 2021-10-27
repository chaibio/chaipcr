import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';

@Component({
    templateUrl: './users.component.html',
    styleUrls: ['./users.component.scss']
})
export class ManageUsersComponent {

    public users: Array<any>;

    constructor(private router: Router) {
        this.users = [
            {name: "Andre", admin: true},
            {name: "Draymond", admin: false},
            {name: "Jonathan", admin: true},
            {name: "Kevin", admin: false},
            {name: "Steph", admin: true},
            {name: "Andre", admin: true},
            {name: "Jonathan", admin: false},
            {name: "Kevin", admin: true},
        ]
    }

    onGoHome(){
        this.router.navigate(['/']);
    }

    onNewUser(){
        this.router.navigate(['/setting/users/new']);
    }
}
