import { Injectable } from '@angular/core';
import { CanDeactivate } from '@angular/router';
import { NewUserComponent } from './new-user.component';

@Injectable()
export class NewUserGuard implements CanDeactivate<NewUserComponent> {

    canDeactivate(target: NewUserComponent) {
        if (target.hasChanges) {
            return target.confirmSaveData();
        }
        return true;
    }

}