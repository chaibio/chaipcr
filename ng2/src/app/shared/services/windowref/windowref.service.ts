import { Injectable } from '@angular/core'

@Injectable()
export class WindowRef {
  nativeWindow: Window = window;
}