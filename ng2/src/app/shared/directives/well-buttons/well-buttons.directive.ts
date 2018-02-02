import {
  Directive,
  Input,
  Output,
  EventEmitter,
  OnChanges,
  SimpleChanges
} from '@angular/core';

import { WellButtonI } from '../../models/well-button.model';

@Directive({
  selector: '[chai-well-buttons]'
})
export class WellButtonsDirective implements OnChanges {
  
  @Input() wells: Array<WellButtonI>;
  @Output() onSelectWells = new EventEmitter<Array<WellButtonI>>();

  ngOnChanges(changes: SimpleChanges):void {
  
  }

}
