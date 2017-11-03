import { TestBed, inject } from '@angular/core/testing';

import { RouterTestingModule } from '@angular/router/testing';
import { Router } from '@angular/router';

import { LoginRouteGuard } from './login.route.guard';

describe('Login Route Guard', () => {

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [RouterTestingModule],
      providers: [
        LoginRouteGuard
      ]
    })
  })

  it('should navigate to home page when token is present', inject(
    [LoginRouteGuard, Router],
    (guard: LoginRouteGuard, router: Router) => {

      spyOn(router, 'navigate').and.callThrough()
      spyOn(localStorage, 'getItem').and.callFake(() => { return 'xxxx'; })
      expect(guard.canActivate()).toBe(false)
      expect(router.navigate).toHaveBeenCalledWith(['/'])

    }))

  it('should allow navigation to /login', inject(
    [LoginRouteGuard, Router],
    (guard: LoginRouteGuard, router: Router) => {

      spyOn(router, 'navigate').and.callThrough()
      spyOn(localStorage, 'getItem').and.callFake(() => { return null; })
      expect(guard.canActivate()).toBe(true)

    }))

})
