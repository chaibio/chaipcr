import { TestBed, async } from '@angular/core/testing';
import { RouterModule } from '@angular/router';
import { RouterTestingModule } from '@angular/router/testing';

import { SharedModule } from './shared/shared.module';
import { AppRoutesModule } from './app.routing.module';
import { AppComponent } from './app.component';
import { DashboardModule } from './components/dashboard/dashboard.module';

import { NgModule } from '@angular/core';
@NgModule()
class MockRoutingModule {}

describe('AppComponent', () => {
  beforeEach(async(() => {
    TestBed.configureTestingModule({
      imports: [
        SharedModule,
        //AppRoutesModule,
        RouterTestingModule,
        DashboardModule,
      ],
      providers: [
      ],
      declarations: [
        AppComponent
      ],
    }).compileComponents();
  }));

  it('should create the app', async(() => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.debugElement.componentInstance;
    expect(app).toBeTruthy();
  }));

  it('should have router-outlet', async(() => {
    const fixture = TestBed.createComponent(AppComponent);
    fixture.detectChanges();
    const compiled = fixture.debugElement.nativeElement;
    expect(compiled.querySelector('router-outlet')).toBeTruthy();
  }));
});
