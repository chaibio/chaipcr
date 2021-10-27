import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';

@Component({
    selector: 'setting-nav',
    templateUrl: './setting-nav.component.html',
    styleUrls: ['./setting-nav.component.scss']
})
export class SettingNavComponent {

    @Input() crumbItems: Array<any> = [];
    constructor(private router: Router) {
    }

    onClose(){
        this.router.navigate(['/']);
    }
}
