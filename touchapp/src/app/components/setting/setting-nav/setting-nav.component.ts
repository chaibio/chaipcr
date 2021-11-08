import { Component, Input, OnInit, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { Subscription } from 'rxjs';
import { BreadCrumbsService, BreadPaths } from '../../../services/breadcrumbs.service';

@Component({
    selector: 'setting-nav',
    templateUrl: './setting-nav.component.html',
    styleUrls: ['./setting-nav.component.scss']
})
export class SettingNavComponent implements OnInit, OnDestroy {
    public breadcrumbSub: Subscription;

    public crumbItems: Array<any> = [];
    constructor(private router: Router, private breadCrumbs: BreadCrumbsService) {
    }

    onClose(){
        this.router.navigate(['/']);
    }

    ngOnInit() {
        this.breadcrumbSub = this.breadCrumbs.on(BreadPaths.settingPath, (items) => {
          this.crumbItems = items
        })
    }

    ngOnDestroy() {
        this.breadcrumbSub.unsubscribe();
    }
}
