import {
  Component,
  ElementRef,
  Renderer,
  OnInit
} from '@angular/core';

import { Router } from '@angular/router'

import { SessionService } from '../../services/session.service'

@Component({
  selector: '[logout]',
  template: `<ng-content></ng-content>`
})
export class LogoutComponent implements OnInit {

  constructor(
    private elementRef: ElementRef,
    private renderer: Renderer,
    private sessionService: SessionService,
    private router: Router
  ) {}

  ngOnInit() {
    // Listen to click events in the component
    this.renderer.listen(this.elementRef.nativeElement, 'click', (event) => {
      this.logout()
    })
  }

  logout() {
    this.sessionService.logout().subscribe((res) => {
      this.router.navigate(['/login'])
    })
  }

}
