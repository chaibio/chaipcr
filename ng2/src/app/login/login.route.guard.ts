
// Redirects users to home if authenticated

import {Injectable} from '@angular/core';
import {Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot} from '@angular/router';
import {Observable} from 'rxjs/Observable';

@Injectable()
export class LoginRouteGuard implements CanActivate {

  constructor (private router: Router) {}

  canActivate(): boolean {
    console.log(this.loggedIn())
    if (this.loggedIn()) {
      this.router.navigate(['/']);
      return false;
    } else {
      return true;
    }
  }

  private loggedIn (): boolean {

    let token = localStorage.getItem('token');
    return !!token;

  }

}