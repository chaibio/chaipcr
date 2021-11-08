import { Injectable } from '@angular/core';
import { Subject, Subscription, Observable } from 'rxjs';
import { filter, map } from 'rxjs/operators';

@Injectable()
export class BreadCrumbsService {
  subject = new Subject<any>();
  constructor() { }

  on(event: BreadPaths, action: any): Subscription {
    return this.subject
      .pipe(
          filter((e: EmitPathEvent) => {
            return e.name === event;
          }),
          map((event: EmitPathEvent) => {
            return event.value;
          })
        )
          .subscribe(action);
  }

  emit(event: EmitPathEvent) {
    this.subject.next(event);
  }
}

export class EmitPathEvent {
  constructor(public name: any, public value?: any) { }
}

export enum BreadPaths {
  settingPath,
}
