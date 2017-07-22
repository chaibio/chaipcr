import {
  TestBed,
  async,
  inject,
  ComponentFixture,
} from '@angular/core/testing'

import { ExperimentListComponent } from './experiment-list.component'
import { ExperimentService, ExperimentListItem } from '../../../shared'

const mockExperiments: ExperimentListItem[] = [
  {
    id: 1,
    name: 'exp 1',
    type: 'string',
    started_at: 'string',
    completed_at: 'string',
    completion_message: 'string',
    completion_status: 'string',
    created_at: 'string',
    time_valid: true
  },
  {
    id: 2,
    name: 'exp 2',
    type: 'string',
    started_at: 'string',
    completed_at: 'string',
    completion_message: 'string',
    completion_status: 'string',
    created_at: 'string',
    time_valid: true
  }
]

let fixture: ComponentFixture<any>;
let component: ExperimentListComponent;

const mockExperimentService = {
  getExperiments: () => {
    return {
      subscribe: (successCb) => {
        successCb(mockExperiments)
      }
    }
  }
}

describe('ExperimentListComponent', () => {

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [
        ExperimentListComponent
      ],
      providers: [
        { provide: ExperimentService, useValue: mockExperimentService }
      ]
    }).compileComponents()
  })

  describe('When fetching experiments', () => {

    beforeEach(inject(

      [ExperimentService],
      (expService: ExperimentService) => {

        fixture = TestBed.createComponent(ExperimentListComponent)
        component = fixture.componentInstance
        fixture.detectChanges()

      }
    ))

    it('should fetch experiments', inject(
      [ExperimentService],
      (expService: ExperimentService) => {

        expect(component.experiments).toEqual(mockExperiments)

      }
    ))

    it('should display experiments', inject(
      [ExperimentService],
      (expService: ExperimentService) => {

        let el = fixture.debugElement.nativeElement

        expect(el.querySelectorAll('.exp-list-item').length).toBe(2)
        expect(el.querySelectorAll('.exp-list-item')[0].innerHTML).toContain(mockExperiments[0].name)
        expect(el.querySelectorAll('.exp-list-item')[1].innerHTML).toContain(mockExperiments[1].name)

      }
    ))

  })

})