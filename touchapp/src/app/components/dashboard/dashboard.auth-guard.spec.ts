import { TestBed, inject } from '@angular/core/testing';

import { RouterTestingModule } from '@angular/router/testing';
import { Router } from '@angular/router';

import { DashboardAuthGuard } from './dashboard.auth-guard';

describe('DashboardAuthGuard', () => {

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [RouterTestingModule],
      providers: [
        DashboardAuthGuard
      ]
    })
  })

  describe('canActivate method', () => {

    it('should redirect to login page when token is not present', inject(
      [DashboardAuthGuard, Router],
      (guard: DashboardAuthGuard, router: Router) => {

        spyOn(router, 'navigate').and.returnValue(true)
        spyOn(localStorage, 'getItem').and.callFake(() => { return null; })
        expect(guard.canActivate()).toBe(false)
        expect(router.navigate).toHaveBeenCalledWith(['/login'])

      }))

    // it('should allow navigation to /login', inject(
    it('should allow navigation to home page when token is present', inject(
      [DashboardAuthGuard, Router],
      (guard: DashboardAuthGuard, router: Router) => {

        spyOn(router, 'navigate').and.callThrough()
        spyOn(localStorage, 'getItem').and.callFake(() => { return 'asdf'; })
        expect(guard.canActivate()).toBe(true)

      }))

  })

  describe('canActivateChild method', () => {

    it('should redirect to login page when token is not present', inject(
      [DashboardAuthGuard, Router],
      (guard: DashboardAuthGuard, router: Router) => {

        spyOn(router, 'navigate').and.returnValue(true)
        spyOn(localStorage, 'getItem').and.callFake(() => { return null; })
        expect(guard.canActivateChild()).toBe(false)
        expect(router.navigate).toHaveBeenCalledWith(['/login'])

      }))

    // it('should allow navigation to /login', inject(
    it('should allow navigation to home page when token is present', inject(
      [DashboardAuthGuard, Router],
      (guard: DashboardAuthGuard, router: Router) => {

        spyOn(router, 'navigate').and.callThrough()
        spyOn(localStorage, 'getItem').and.callFake(() => { return 'asdf'; })
        expect(guard.canActivateChild()).toBe(true)

      }))

  })

})