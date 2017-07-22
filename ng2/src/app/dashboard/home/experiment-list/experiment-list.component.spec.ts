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

    it(`should toggle editing mode`, async(() => {
      let el = fixture.debugElement.nativeElement
      let button = <HTMLButtonElement>el.querySelector('#edit-button')

      button.click()
      fixture.detectChanges()

      expect(button.classList.contains('editing')).toBe(true)

      let container = el.querySelector('.experiment-list-container')
      expect(container.classList.contains('editing')).toBe(true)

      button.click()
      fixture.detectChanges()

      expect(button.classList.contains('editing')).toBe(false)
      expect(container.classList.contains('editing')).toBe(false)


    }))

    it(`should revert to non-editing mode when [ESC] key is pressed`, async(() => {

      fixture.componentInstance.editing = true
      fixture.detectChanges()

      let ev = new KeyboardEvent("keydown", {
        code: '27'
      })

      document.dispatchEvent(ev)
      fixture.detectChanges()

      let el = fixture.debugElement.nativeElement
      let button = <HTMLButtonElement>el.querySelector('#edit-button')
      let container = el.querySelector('.experiment-list-container')
      expect(button.classList.contains('editing')).toBe(false)
      expect(container.classList.contains('editing')).toBe(false)

    }))

  })

})