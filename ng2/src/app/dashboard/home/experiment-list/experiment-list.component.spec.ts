import {
  TestBed,
  async,
  inject
} from '@angular/core/testing'

import { ExperimentListComponent } from './experiment-list.component'
import { ExperimentService, ExperimentListItem } from '../../../shared'

const mockExperiments: ExperimentListItem[] = [
  {
    id: 1,
    name: 'string',
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
    name: 'string',
    type: 'string',
    started_at: 'string',
    completed_at: 'string',
    completion_message: 'string',
    completion_status: 'string',
    created_at: 'string',
    time_valid: true
  }
]

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

  it('should fetch experiments', inject(
    [ExperimentService],
    (expService: ExperimentService) => {

      let fixture = TestBed.createComponent(ExperimentListComponent)
      let component = fixture.componentInstance

      fixture.detectChanges()
      expect(component.experiments).toEqual(mockExperiments)

    }
  ))

})