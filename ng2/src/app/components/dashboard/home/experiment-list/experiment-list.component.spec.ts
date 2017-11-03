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

import { ExperimentService } from '../../../../shared/services/experiment/experiment.service'
import { ExperimentList } from '../../../../shared/models/experiment-list.model'

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
  },
  deleteExperiment: () => { }
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

    it('should show loading text and no experiments text', async(() => {

      fixture.componentInstance.experiments = undefined

      fixture.detectChanges()

      let listContainer: HTMLDivElement = fixture.nativeElement.querySelector('.exp-list-container')
      let loadingContainer: HTMLDivElement = fixture.nativeElement.querySelector('.exp-list-loading-container')
      let emptyContainer: HTMLDivElement = fixture.nativeElement.querySelector('.exp-list-empty-container')

      expect(listContainer).toBeNull()
      expect(emptyContainer).toBeNull()
      expect(loadingContainer.querySelector('p').textContent).toContain('Loading experiments')

      fixture.componentInstance.experiments = []
      fixture.detectChanges()

      listContainer = fixture.nativeElement.querySelector('.exp-list-container')
      loadingContainer = fixture.nativeElement.querySelector('.exp-list-loading-container')
      emptyContainer = fixture.nativeElement.querySelector('.exp-list-empty-container')

      expect(listContainer).toBeNull()
      expect(loadingContainer).toBeNull()
      expect(emptyContainer.querySelector('p').textContent).toContain('No experiments yet')

    }
    ))

    it('should fetch experiments', inject(
      [ExperimentService],
      (expService: ExperimentService) => {

        const expectedList: ExperimentListItem[] = mockExperiments.map(exp => {
          return {
            model: exp,
            confirmDelete: false,
            deleting: false,
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

  describe('When on editing mode and trash icon is clicked', () => {

    beforeEach(() => {
      fixture.componentInstance.editing = true
      fixture.detectChanges()
    })

    it(`should add "confirm-delete" class to experiment list item`, async(() => {

      let el = fixture.debugElement.nativeElement
      let listItem = <HTMLLIElement>el.querySelector('li.exp-list-item')
      let button = <HTMLDivElement>listItem.querySelector('.delete-icon')

      button.click()
      fixture.detectChanges()

      expect(listItem.classList.contains('confirm-delete')).toBe(true)

    }))

    it(`should remove "confirm-delete" class to experiment list item when out of focus`, async(() => {

      let el = fixture.debugElement.nativeElement
      let listItem = <HTMLLIElement>el.querySelector('li.exp-list-item')
      let button = <HTMLDivElement>listItem.querySelector('.delete-icon')

      button.click()
      fixture.detectChanges()
      expect(listItem.classList.contains('confirm-delete')).toBe(true)

      setTimeout(() => {
        listItem.querySelector('button').blur()
        fixture.detectChanges()
        expect(listItem.classList.contains('confirm-delete')).toBe(false)
      }, 501)

    }))

    it(`should remove "confirm-delete" class when [ESC] key is pressed`, async(() => {

      fixture.componentInstance.editing = true

      fixture.componentInstance.experiments.forEach((exp: ExperimentListItem) => {
        exp.confirmDelete = true
      })

      fixture.detectChanges()

      let ev = new KeyboardEvent("keydown", {
        code: '27'
      })

      document.dispatchEvent(ev)
      fixture.detectChanges()

      let listItems: HTMLLIElement[] = fixture.nativeElement.querySelectorAll('li.exp-list-item')

      listItems.forEach(li => {
        expect(li.classList.contains('confirm-delete')).toBe(false)
      })

    }))

  })

  describe('When clicking ok button', () => {

    beforeEach(() => {
      fixture.componentInstance.editing = true

      fixture.componentInstance.experiments.forEach((exp: ExperimentListItem) => {
        exp.confirmDelete = true
      })

      fixture.detectChanges()

    })

    it('should delete the experiment', inject([ExperimentService], (expService: ExperimentService) => {

      let callback: any;
      spyOn(expService, 'deleteExperiment').and.callFake(() => {
        return {
          subscribe: (successCb) => {
            callback = successCb
          }
        }
      })

      let li: HTMLLIElement = fixture.nativeElement.querySelector('li.exp-list-item')
      let okButton: HTMLButtonElement = fixture.nativeElement.querySelector('.delete-button')
      okButton.click()
      fixture.detectChanges()

      expect(expService.deleteExperiment).toHaveBeenCalledWith(mockExperiments[0].id)
      expect(li.classList.contains('deleting')).toBe(true)
      callback()

      fixture.detectChanges()

      expect(fixture.componentInstance.experiments.length).toBe(mockExperiments.length - 1)

    }))

  })

})
