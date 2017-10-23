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
let expUpdatesCB: any = null;
const ExperimentServiceMock = {
  $updates: {
    subscribe: (cb) => {
      expUpdatesCB = cb;
    }
  },
  getExperiment: () => {
    return {
      subscribe: (cb) => {
        getExperimentCB = cb;
      }
    }
  }
}

@Component({
  template: `<div chai-header-status [experiment-id]="id"></div>`
})
class TestingComponent {
  public id: number
}

describe('HeaderStatusComponent Directive', () => {

  let exp: any;

  beforeEach(async(() => {

    spyOn(ExperimentServiceMock, 'getExperiment').and.callThrough()
    exp = JSON.parse(JSON.stringify(ExperimentMockInstance));

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

      let fixture = TestBed.createComponent(TestingComponent);
      let component = fixture.componentInstance;
      fixture.detectChanges();
      expect(ExperimentServiceMock.getExperiment).not.toHaveBeenCalled();
      expect(fixture.debugElement.nativeElement.querySelector('.exp-name').innerHTML.trim()).toBe('Loading...')
      component.id = ExperimentMockInstance.id;
      fixture.detectChanges();
      expect(ExperimentServiceMock.getExperiment).toHaveBeenCalledWith(component.id);
      getExperimentCB(ExperimentMockInstance);
      fixture.detectChanges();
      expect(fixture.debugElement.nativeElement.querySelector('.exp-name').innerHTML.trim()).toBe(ExperimentMockInstance.name)

    }))

  describe('When status is idle', () => {

    let statusData: any;

    beforeEach(async(() => {

      statusData = mockStatusReponse;
      statusData.experiment_controller.machine.state = "idle"

    }))

    describe('When experiment is complete', () => {

      beforeEach(() => {
        ExperimentMockInstance.id = 1;
        expect(ExperimentMockInstance.started_at).toBeTruthy();
        expect(ExperimentMockInstance.completed_at).toBeTruthy();

        this.fixture = TestBed.createComponent(TestingComponent);
        this.fixture.componentInstance.id = ExperimentMockInstance.id;
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

        exp.completed_at = null;
        expect(exp.started_at).toBeTruthy();

        this.fixture = TestBed.createComponent(TestingComponent);
        this.fixture.componentInstance.id = ExperimentMockInstance.id;
        this.fixture.detectChanges();

      })

      it('should show user cancelled', inject(
        [StatusService],
        (statusService: StatusService) => {

          ExperimentMockInstance.completion_status = 'aborted';

          getExperimentCB(exp);
          this.fixture.detectChanges();

          statusService.$data.next(statusData);
          this.fixture.detectChanges();
          let el = this.fixture.debugElement.nativeElement.querySelector('.status-indicator .message-text');
          let failedEl = this.fixture.debugElement.nativeElement.querySelector('.status-indicator .failed');

          expect(failedEl.innerHTML.trim()).toBe('FAILED');
          expect(el.innerHTML.trim()).toContain('USER CANCELLED');
        }
      ))

      it('should show an error occured', inject(
        [StatusService],
        (statusService: StatusService) => {

          exp.completion_status = 'some error';

          getExperimentCB(exp);
          this.fixture.detectChanges();

          statusService.$data.next(statusData);
          this.fixture.detectChanges();
          let el = this.fixture.debugElement.nativeElement.querySelector('.status-indicator .message-text');
          let failedEl = this.fixture.debugElement.nativeElement.querySelector('.status-indicator .failed');
          expect(failedEl.innerHTML.trim()).toBe('FAILED');
          expect(el.innerHTML.trim()).toContain('AN ERROR OCCURED');
        }
      ))

    })

  })

  describe('When experiment is running', () => {

    let exp: any
    let statusData: any;

    beforeEach(async(() => {

      exp = JSON.parse(JSON.stringify(ExperimentMockInstance));
      statusData = JSON.parse(JSON.stringify(StatusDataMockInstance));
      statusData.experiment_controller.machine.state = "running";

    }))

    it('should subscribe to experiment service updates', inject(
      [ExperimentService, StatusService],
      (expService:ExperimentService, statusService:StatusService) => {

        spyOn(expService.$updates, 'subscribe').and.callThrough();

        statusData.experiment_controller.experiment.id = exp.id;

        this.fixture = TestBed.createComponent(TestingComponent);
        // it should not subscribe when expid is null
        statusService.$data.next(statusData);
        this.fixture.detectChanges();
        expect(expService.$updates.subscribe).not.toHaveBeenCalled()

        // it shoud subscribe when exp id is present and current is current experient running
        this.fixture.componentInstance.id = exp.id;
        this.fixture.detectChanges();
        statusService.$data.next(statusData);
        this.fixture.detectChanges();
        expect(expService.$updates.subscribe).toHaveBeenCalled();
      }
    ))

    it('should NOT subscribe to experiment service updates if not current experiment', inject(
      [ExperimentService, StatusService],
      (expService:ExperimentService, statusService:StatusService) => {

        spyOn(expService.$updates, 'subscribe').and.callThrough();

        statusData.experiment_controller.experiment.id = 9876;

        this.fixture = TestBed.createComponent(TestingComponent);
        // it should not subscribe when expid is null
        statusService.$data.next(statusData);
        this.fixture.detectChanges();
        expect(expService.$updates.subscribe).not.toHaveBeenCalled()

        // it shoud subscribe when exp id is present and current is current experient running
        this.fixture.componentInstance.id = exp.id;
        this.fixture.detectChanges();
        statusService.$data.next(statusData);
        this.fixture.detectChanges();
        expect(expService.$updates.subscribe).not.toHaveBeenCalled();
      }
    ))

    describe('When experiment is in holding state', () => {

      beforeEach(async(() => {
        exp.started_at = "2017-08-30T16:30:13.000Z";
        exp.completed_at = "2017-08-30T16:30:13.000Z";

        this.fixture = TestBed.createComponent(TestingComponent);
        this.fixture.componentInstance.id = exp.id;
        this.fixture.detectChanges();
      }))

      it('should display analyzing', inject(
        [StatusService],
        (statusService: StatusService) => {
          getExperimentCB(exp);
          this.fixture.detectChanges();
          statusService.$data.next(statusData);
          this.fixture.detectChanges();
          let el = this.fixture.debugElement.nativeElement;
          expect(el.querySelector('.status-indicator .message-text').innerHTML.trim()).toBe(`Analyzing... Holding Temperature of ${statusData.heat_block.temperature.toFixed(1)}`);
        }
      ))

      it('should display experiment complete, holding temperature', inject(
        [StatusService],
        (statusService: StatusService) => {
          getExperimentCB(exp);
          this.fixture.detectChanges();
          statusService.$data.next(statusData);
          this.fixture.detectChanges();
          expUpdatesCB('experiment:completed');
          this.fixture.detectChanges();
          let el = this.fixture.debugElement.nativeElement;
          expect(el.querySelector('.status-indicator .message-text').innerHTML.trim()).toBe(`Experiment Complete, Holding Temperature of ${statusData.heat_block.temperature.toFixed(1)}`);
        }
      ))

    })

    describe('When another experiment is running', () => {

      let exp: any;
      let statusData: any;

      beforeEach(async(() => {
        exp = JSON.parse(JSON.stringify(ExperimentMockInstance));
        statusData = JSON.parse(JSON.stringify(StatusDataMockInstance));
        exp.id = 1;
        statusData.experiment_controller.experiment.id = 1233423423;
      }))

      describe('When experiment has not been started', () => {

        beforeEach(() => {
          exp.started_at = null;
          exp.completed_at = null;
        })

        it('should display another experiment is running', inject(
          [ExperimentService, StatusService],
          (expService: ExperimentService, statusService: StatusService) => {
            this.fixture = TestBed.createComponent(TestingComponent);
            this.fixture.componentInstance.id = exp.id;
            this.fixture.detectChanges();
            getExperimentCB(exp);
            this.fixture.detectChanges();
            statusService.$data.next(statusData);
            this.fixture.detectChanges();
            let el = this.fixture.debugElement.nativeElement;
            expect(el.querySelector('.message-text').innerHTML.trim()).toBe('ANOTHER EXPERIMENT IS RUNNING');
            expect(el.querySelector('.message .button').innerHTML.trim()).toBe('VIEW NOW');
          }
        ));


      });

    });

  })

})

