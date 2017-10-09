import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  TestBed,
  async,
  inject
} from '@angular/core/testing';
import {
  HttpModule,
  XHRBackend
} from '@angular/http';
import {
  MockConnection,
  MockBackend
} from '@angular/http/testing';

import { AuthHttp } from '../../services/auth_http/auth_http.service';
import { StatusService } from '../../services/status/status.service';
import { ExperimentService } from '../../services/experiment/experiment.service';
import { HeaderStatusComponent } from './header-status.component';
import { ExperimentMockInstance } from '../../models/experiment.model.mock';
import { StatusDataMockInstance } from '../../models/status.model.mock';
import { mockStatusReponse } from '../../services/status/mock-status-response';
import { WindowRef } from '../../services/windowref/windowref.service';

let getExperimentCB: any = null;
const ExperimentServiceMock = {
  getExperiment: () => {
    return {
      subscribe: (cb) => {
        getExperimentCB = cb;
      }
    }
  }
}

describe('HeaderStatusComponent Directive', () => {

  beforeEach(async(() => {
    spyOn(ExperimentServiceMock, 'getExperiment').and.callThrough()
    @Component({
      template: `<div chai-header-status experiment-id="1"></div>`
    })
    class TestingComponent {}

    this.TestingComponent = TestingComponent;

    TestBed.configureTestingModule({
      imports: [
        CommonModule,
        HttpModule
      ],
      declarations: [
        TestingComponent,
        HeaderStatusComponent
      ],
      providers: [
        {
          provide: ExperimentService,
          useValue: ExperimentServiceMock
        },
        WindowRef,
        StatusService,
        AuthHttp
      ]
    }).compileComponents()

  }))

  it('should show loading text initially', inject(
    [ExperimentService],
    (expService: ExperimentService) => {

      let fixture = TestBed.createComponent(this.TestingComponent);
      let component = fixture.componentInstance;
      fixture.detectChanges();
      expect(ExperimentServiceMock.getExperiment).toHaveBeenCalledWith(1);
      expect(fixture.debugElement.nativeElement.querySelector('.exp-name').innerHTML.trim()).toBe('Loading...')
      getExperimentCB(ExperimentMockInstance);
      fixture.detectChanges();
      expect(fixture.debugElement.nativeElement.querySelector('.exp-name').innerHTML.trim()).toBe(ExperimentMockInstance.name)

    }))

  describe('When status is idle', () => {

    let statusData: any;

    beforeEach(() => {

      statusData = mockStatusReponse;
      statusData.experiment_controller.machine.state = "idle"

    })

    describe('When experiment is complete', () => {

      beforeEach(() => {
        expect(ExperimentMockInstance.started_at).toBeTruthy();
        expect(ExperimentMockInstance.completed_at).toBeTruthy();
        expect(ExperimentMockInstance.id).toBeTruthy(1);

        this.fixture = TestBed.createComponent(this.TestingComponent);
        this.fixture.detectChanges();
        getExperimentCB(ExperimentMockInstance);
        this.fixture.detectChanges();
      })

      it('should show completed experiment', inject(
        [ExperimentService, StatusService],
        (expService: ExperimentService, statusService: StatusService) => {

          statusService.$data.next(statusData)
          this.fixture.detectChanges();
          let el = this.fixture.debugElement.nativeElement.querySelector('.status-indicator > .message');
          expect(el.innerHTML.trim()).toBe('COMPLETED')

        }))

    })

    describe('When experiment failed', () => {

      beforeEach(() => {

        ExperimentMockInstance.completed_at = null;
        expect(ExperimentMockInstance.started_at).toBeTruthy();

        this.fixture = TestBed.createComponent(this.TestingComponent);
        this.fixture.detectChanges();


      })

      it('should show user cancelled', inject(
        [StatusService],
        (statusService: StatusService) => {

          ExperimentMockInstance.completion_status = 'aborted';

          getExperimentCB(ExperimentMockInstance);
          this.fixture.detectChanges();

          statusService.$data.next(statusData);
          this.fixture.detectChanges();
          let el = this.fixture.debugElement.nativeElement.querySelector('.status-indicator .message-text');
          let failedEl = this.fixture.debugElement.nativeElement.querySelector('.status-indicator .failed');
          expect(failedEl.innerHTML.trim()).toBe('FAILED')
          expect(el.innerHTML.trim()).toContain('USER CANCELLED')
        }
      ))

      it('should show an error occured', inject(
        [StatusService],
        (statusService: StatusService) => {

          ExperimentMockInstance.completion_status = 'some error';

          getExperimentCB(ExperimentMockInstance);
          this.fixture.detectChanges();

          statusService.$data.next(statusData);
          this.fixture.detectChanges();
          let el = this.fixture.debugElement.nativeElement.querySelector('.status-indicator .message-text');
          let failedEl = this.fixture.debugElement.nativeElement.querySelector('.status-indicator .failed');
          expect(failedEl.innerHTML.trim()).toBe('FAILED')
          expect(el.innerHTML.trim()).toContain('AN ERROR OCCURED')
        }
      ))


    })

  })

})

