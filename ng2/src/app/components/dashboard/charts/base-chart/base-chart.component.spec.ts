import {
  TestBed,
  async,
  inject
} from '@angular/core/testing';

import { Component } from '@angular/core';
import * as d3 from 'd3'

@Component({
  template: `<div chai-base-chart [data]="data" [config]="config"></div>`
})
class TestingComponent {
  public data: any;
  public config: any;
}

fdescribe('BaseChart Component', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      declarations: [
        TestingComponent
      ]
    }).compileComponents()

  }))

  it('should NOT initalize chart when data/config isnt initialized', () => {
  
    let fixture = TestBed.createComponent(TestingComponent)
    fixture.detectChanges()
    expect(fixture.debugElement.nativeElement.innerHTML.trim()).toBe('')
  
  })


})
