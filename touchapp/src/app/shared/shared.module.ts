import { NgModule } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { RouterModule } from '@angular/router';
import {
  CommonModule,
  APP_BASE_HREF
} from '@angular/common';

import { LogoutDirective } from './directives/logout/logout.directive';
import { FullHeightDirective } from './directives/full-height/full-height.directive';
import { FullWidthDirective } from './directives/full-width/full-width.directive';
import { ClickOutsideDirective } from './directives/click-outside/click-outside.directive';

import { HeaderStatusComponent } from './directives/header-status/header-status.component';
import { HrMinSecPipe } from './pipes/hr-min-secs/hr-min-secs.pipe';
import { BaseChartDirective } from './directives/charts/base-chart/base-chart.directive'
import { AmplificationChartDirective } from './directives/charts/amplification-chart/amplification-chart.directive'
import { WellButtonsComponent } from './components/well-buttons/well-buttons.component';
import { ToggleSwitchComponent } from './components/toggle-switch/toggle-switch.component';
import { PasswordEditorComponent } from './components/password-editor/password-editor.component';

import { ConfirmModalComponent } from './modals/confirm-modal/confirm-modal.component';
import { ConfirmModalService } from './modals/confirm-modal/confirm-modal.service';

@NgModule({
  declarations: [
    LogoutDirective,
    FullHeightDirective,
    FullWidthDirective,
    ClickOutsideDirective,

    BaseChartDirective,
    AmplificationChartDirective,
    WellButtonsComponent,
    ToggleSwitchComponent,
    HeaderStatusComponent,
    HrMinSecPipe,
    PasswordEditorComponent,

    ConfirmModalComponent,
  ],
  imports: [
    FormsModule,
    HttpModule,
    CommonModule,
  ],
  exports: [
    RouterModule,
    FormsModule,
    HttpModule,
    CommonModule,
    LogoutDirective,
    FullHeightDirective,
    FullWidthDirective,
    ClickOutsideDirective,

    HeaderStatusComponent,
    BaseChartDirective,
    AmplificationChartDirective,
    WellButtonsComponent,
    ToggleSwitchComponent,
    HrMinSecPipe,
    PasswordEditorComponent,
  ],
  providers: [
    Title,
    { provide: APP_BASE_HREF, useValue: '/' },
    ConfirmModalService,
  ],
  entryComponents: [
    ConfirmModalComponent
  ],
})

export class SharedModule { }
