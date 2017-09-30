import { TestBed, async, inject } from '@angular/core/testing'

import { Title } from '@angular/platform-browser'
import { RouterTestingModule } from '@angular/router/testing'
import { XHRBackend } from '@angular/http'
import { MockBackend } from '@angular/http/testing'
import { HomeComponent } from './home.component'
import { ExperimentListComponent } from './experiment-list/experiment-list.component'
import { SharedModule } from '../../shared/shared.module'

describe('HomeComponent', () => {

  beforeEach(async(() => {

    TestBed.configureTestingModule({
      imports: [
        RouterTestingModule,
        SharedModule
      ],
      providers: [
        { provide: XHRBackend, useClass: MockBackend }
      ],
      declarations: [
        HomeComponent,
        ExperimentListComponent,
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
