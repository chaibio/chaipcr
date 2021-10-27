import { Component, OnDestroy, OnInit } from '@angular/core';
import { StatusService } from '../../services/status/status.service'
import { Title } from '@angular/platform-browser'

@Component({
    templateUrl: './setting.component.html',
    styleUrls: ['./setting.component.scss']
})
export class SettingComponent implements OnDestroy, OnInit {
    public crumbItems: Array<any>;

    constructor(private statusService: StatusService, private title: Title) {
        // statusService.startSync();
    }

    ngOnInit(){
        this.crumbItems = [
            { name: 'Settings', current: false },
            { name: 'Manage Users', current: true },
        ]
    }

    ngOnDestroy() {
        // this.statusService.stopSync()
    }

}
