import {
  TestBed,
  async,
  inject,
  ComponentFixture,
} from '@angular/core/testing'

import {
  ExperimentListComponent,
  ExperimentListItem,
} from './experiment-list.component'

import {
  ExperimentService,
  ExperimentList
} from '../../../shared'

const mockExperiments: ExperimentList[] = [
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

let fixture: ComponentFixture<ExperimentListComponent>;
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

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [
        ExperimentListComponent
      ],
      providers: [
        { provide: ExperimentService, useValue: mockExperimentService }
      ]
    }).compileComponents().then(() => {
      fixture = TestBed.createComponent(ExperimentListComponent)
      fixture.detectChanges()
      component = fixture.componentInstance
    })
  }))

  describe('When fetching experiments', () => {

    it('should fetch experiments', inject(
      [ExperimentService],
      (expService: ExperimentService) => {

        const expectedList: ExperimentListItem[] = mockExperiments.map(exp => {
          return {
            model: exp,
            open: false
          }
        })
        expect(component.experiments).toEqual(expectedList)
      }

    ))

    it('should display experiments', async(() => {

      let el = fixture.debugElement.nativeElement

      expect(el.querySelectorAll('.exp-list-item').length).toBe(2)
      expect(el.querySelectorAll('.exp-list-item')[0].innerHTML).toContain(mockExperiments[0].name)
      expect(el.querySelectorAll('.exp-list-item')[1].innerHTML).toContain(mockExperiments[1].name)

    }
    ))

  })

  describe('When edit button is clicked', () => {

    it('should open the delete icon of each experiment in the list', async(() => {
      
    }))

  })

  describe('When list item is clicked', () => {

    it(`should add "open" class to experiment list item`, async(() => {
      let el = fixture.debugElement.nativeElement
      let anchor = <HTMLAnchorElement>el.querySelector('.exp-list-item > a')

      anchor.click()

      fixture.detectChanges()

      let item = el.querySelector('.exp-list-item')
      expect(item.classList.contains('open')).toBe(true)

    }))

  })

})