import { Component, Input, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { BreadCrumbsService, EmitPathEvent, BreadPaths } from '../../../services/breadcrumbs.service';

@Component({
    templateUrl: './home.component.html',
    styleUrls: ['./home.component.scss']
})
export class SettingHomeComponent implements OnInit {

    @Input() items: Array<any> = [];

    constructor(private router: Router, private breadCrumbs: BreadCrumbsService) {
    }

    ngOnInit() {
        this.breadCrumbs.emit(new EmitPathEvent(BreadPaths.settingPath, [
            { name: 'Settings', current: true },
        ]));
    }

    onGoHome(){
        this.router.navigate(['/']);
    }

    onGoUsers() {
        this.router.navigate(['/setting/users']);
    }
}
