import { TestBed, async, inject } from '@angular/core/testing';
import { RouterTestingModule } from '@angular/router/testing';

import { SharedModule } from '../../shared/shared.module';
import { DashboardComponent } from './dashboard.component';
import { HomeModule } from './home/home.module';

import { StatusService } from '../../services/status/status.service'
import { ExperimentService } from '../../services/experiment/experiment.service'

const mockExperimentService = {
  getExperiments: () => {
    return {
      subscribe: (cb) => {
        cb([])
      }
    }
  }
}

describe('DashboardComponent', () => {
  beforeEach(async(() => {

    TestBed.configureTestingModule({
      imports: [
        RouterTestingModule,
        SharedModule,
        HomeModule,
      ],
      providers: [StatusService],
      declarations: [
        DashboardComponent
      ]
    }).compileComponents();

  }));

  it('should create the app', () => {
    const fixture = TestBed.createComponent(DashboardComponent);
    const app = fixture.debugElement.componentInstance;
    expect(app).toBeTruthy();
    const compiled = fixture.debugElement.nativeElement;
    expect(compiled.querySelector('router-outlet')).toBeTruthy();
  });

  it('should call statusService.startSync()', inject(
    [StatusService],
    (statusService: StatusService) => {
      spyOn(statusService, 'startSync')
      const fixture = TestBed.createComponent(DashboardComponent)
      expect(statusService.startSync).toHaveBeenCalled()
    }
  ))

  it('should call statusService.stopSync() on destroy event', inject(
    [StatusService],
    (statusService: StatusService) => {
      spyOn(statusService, 'stopSync')
      const fixture = TestBed.createComponent(DashboardComponent)
      fixture.componentInstance.ngOnDestroy()
      expect(statusService.stopSync).toHaveBeenCalled()
    }
  ))


});
