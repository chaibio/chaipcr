import {
  TestBed,
  async,
  inject
} from '@angular/core/testing';

import { Directive } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { HomeComponent } from './home.component';

@Directive({
  selector: 'experiment-list'
})
class ExperimentListComponentMock {}

describe('HomeComponent', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      declarations: [
        HomeComponent,
        ExperimentListComponentMock,
      ]
    }).compileComponents()

  }))

  it('should set title to ChaiPCR | Home',
    inject(
      [Title],
      (title: Title) => {

        spyOn(title, 'setTitle').and.callThrough()

        let fixture = TestBed.createComponent(HomeComponent)
        fixture.detectChanges()
        expect(title.setTitle).toHaveBeenCalledWith('ChaiPCR | Home')

      }
    ))

})
