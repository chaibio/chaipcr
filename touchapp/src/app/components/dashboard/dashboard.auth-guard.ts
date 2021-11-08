import {Injectable} from '@angular/core';
import {Router, CanActivate, CanActivateChild, ActivatedRouteSnapshot, RouterStateSnapshot} from '@angular/router';
import {Observable} from 'rxjs';

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

  canActivateChild(): boolean {
    return this.canActivate()
  }

  private loggedIn (): boolean {
    return true;
    // let token = localStorage.getItem('token');
    // return !!token;
  }

}