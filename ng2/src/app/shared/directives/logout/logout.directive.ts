import {
  Directive,
  ElementRef,
  HostListener,
} from '@angular/core';

import { Router } from '@angular/router'

import { SessionService } from '../../../services/session/session.service'

@Directive({
  selector: '[chai-logout]',
})
export class LogoutDirective {

  constructor(
    private elementRef: ElementRef,
    private sessionService: SessionService,
    private router: Router
  ) { }

  @HostListener('click') doLogout() {
    this.sessionService.logout().subscribe((res) => {
      this.router.navigate(['/login'])
    })
  }

}
