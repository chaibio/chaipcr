import { Injectable } from '@angular/core';
import { CanDeactivate } from '@angular/router';
import { EditUserComponent } from './edit-user.component';

@Injectable()
export class EditUserGuard implements CanDeactivate<EditUserComponent> {

    canDeactivate(target: EditUserComponent) {
        if (target.hasChanges) {
            return target.confirmSaveData();
        }
        return true;
    }

}