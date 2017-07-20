import {Injectable} from '@angular/core';
import {Router, CanActivate, CanActivateChild, ActivatedRouteSnapshot, RouterStateSnapshot} from '@angular/router';
import {Observable} from 'rxjs/Rx';

@Injectable()
export class DashboardAuthGuard implements CanActivate, CanActivateChild {

  constructor (private router: Router) {}

  canActivate(): boolean {
    if (this.loggedIn()) {
      return true;
    } else {
      this.router.navigate(['/login']);
      return false;
    }
  }

  canActivateChild(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean {
    return this.canActivate()
  }

  private loggedIn (): boolean {

    let token = localStorage.getItem('token');
    return !!token;

  }

}