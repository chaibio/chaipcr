import {
  TestBed,
  async,
  inject
} from '@angular/core/testing';

import { Input } from '@angular/core';
import { Directive } from '@angular/core';
import { RouterTestingModule } from '@angular/router/testing';
import { ActivatedRoute } from '@angular/router';

import { ChartsComponent } from './charts.component';

let paramSubCB = null;

const ActivatedRouteMock = {
  params: {
    subscribe: (fn) => {
      paramSubCB = fn;
    }
  }
}

@Directive({
  selector: '[chai-header-status]'
})
class HeaderStatusComponentMock {
  @Input('experiment-id') expId: number;
}

describe('ChartsComponent', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      imports: [
        RouterTestingModule
      ],
      providers: [
        {
          provide: ActivatedRoute,
          useValue: ActivatedRouteMock
        }
      ],
      declarations: [
        ChartsComponent,
        HeaderStatusComponentMock
      ]
    }).compileComponents()

  }))

  it('should create the component', async(() => {
    let fixture = TestBed.createComponent(ChartsComponent);
    const component = fixture.debugElement.componentInstance;
    expect(component).toBeTruthy();
    const compiled = fixture.debugElement.nativeElement;
    expect(compiled.querySelector('router-outlet')).toBeTruthy();
    expect(compiled.querySelector('[chai-header-status]')).toBeTruthy();
  }))

  it('should assign experiment id to header-status directive', inject(
    [],
    () => {
      let fixture = TestBed.createComponent(ChartsComponent);
      const component = fixture.debugElement.componentInstance;
      const compiled = fixture.debugElement.nativeElement;
      fixture.detectChanges();
      const directive: HTMLElement = compiled.querySelector('[chai-header-status]');
      expect(component.experimentId).toBeFalsy();
      paramSubCB({id: 1});
      fixture.detectChanges();
      expect(component.experimentId).toBe(1);
    }
  ))

})
