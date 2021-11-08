
// Redirects users to home if authenticated

import {Injectable} from '@angular/core';
import {Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot} from '@angular/router';

@Injectable()
export class LoginRouteGuard implements CanActivate {

  constructor (private router: Router) {}

  canActivate(): boolean {
    if (this.loggedIn()) {
      this.router.navigate(['/']);
      return false;
    } else {
      return true;
    }
  }

  private loggedIn (): boolean {
    return true;
    // let token = localStorage.getItem('token');
    // return !!token;

  }

}
