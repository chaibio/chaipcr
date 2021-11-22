import { Injectable } from '@angular/core';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';

import { ConfirmModalComponent } from './confirm-modal.component';

@Injectable()
export class ConfirmModalService {

  constructor(private modalService: NgbModal) { }

  public confirm(
    message: string,
    btnOkText: string = 'OK',
    btnCancelText: string = 'Cancel',
    dialogSize: 'sm'|'lg' = 'sm'): Promise<boolean> {
    const modalRef = this.modalService.open(
      ConfirmModalComponent,
      { 
        size: dialogSize,
        backdrop: 'static',
        keyboard: false,
        windowClass: 'confirm-modal'
      }
    );
    modalRef.componentInstance.message = message;
    modalRef.componentInstance.btnOkText = btnOkText;
    modalRef.componentInstance.btnCancelText = btnCancelText;
    return modalRef.result;
  }

}
