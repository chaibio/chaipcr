import { Component, Input, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { BreadCrumbsService, EmitPathEvent, BreadPaths } from '../../../services/breadcrumbs.service';

@Component({
    templateUrl: './users.component.html',
    styleUrls: ['./users.component.scss']
})
export class ManageUsersComponent implements OnInit {

    public users: Array<any>;

    constructor(private router: Router, private breadCrumbs: BreadCrumbsService) {
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

    ngOnInit() {
        this.breadCrumbs.emit(new EmitPathEvent(BreadPaths.settingPath, [
            { name: 'Settings', current: false, path: '/setting' },
            { name: 'Manage Users', current: true },
        ]));
    }

    onGoHome(){
        this.router.navigate(['/']);
    }

    onNewUser(){
        this.router.navigate(['/setting/users/new']);
    }
}
