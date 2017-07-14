import {Injectable} from '@angular/core';
import {Router, CanActivate, CanActivateChild, ActivatedRouteSnapshot, RouterStateSnapshot} from '@angular/router';
import {Observable} from 'rxjs/Rx';

@Injectable()
export class DashboardAuthGuard implements CanActivate, CanActivateChild {

  constructor (private router: Router) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean>|boolean {
    this.router.navigate(['/login']);
    return false;
  }

  canActivateChild(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean>|boolean {
    return this.canActivate(route, state)
  }

}