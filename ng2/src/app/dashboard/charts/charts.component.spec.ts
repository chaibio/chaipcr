import { TestBed, async, inject } from '@angular/core/testing';
import { RouterTestingModule } from '@angular/router/testing';

import { ChartsComponent } from './charts.component';

describe('ChartsComponent', () => {

  beforeEach(async(() => {
    
    TestBed.configureTestingModule({
      imports: [
        RouterTestingModule
      ],
      declarations: [ ChartsComponent ]
    }).compileComponents()

  }))

  it('should create the component', async(() => {
    let fixture = TestBed.createComponent(ChartsComponent);
    const component = fixture.debugElement.componentInstance;
    expect(component).toBeTruthy();
    const compiled = fixture.debugElement.nativeElement;
    expect(compiled.querySelector('router-outlet')).toBeTruthy();
  }))

})
