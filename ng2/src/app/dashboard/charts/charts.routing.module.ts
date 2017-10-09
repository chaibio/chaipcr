import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ChartsComponent } from './charts.component'; 
import { AmplificationComponent } from './amplification/amplification.component';

const routes: Routes = [
  {
    path: '',
    component: ChartsComponent,
    children: [
      {
        path: '',
        component: AmplificationComponent,
      },
      // {
      //   path: 'welcome',
      //   component: WelcomeComponent,
      // },
      // {
      //   path: 'setup/:step',
      //   component: SetupComponent,
      // }
    ]
  }
];

@NgModule({
  imports: [
    RouterModule.forChild(routes)
  ],
  exports: [
    RouterModule
  ],
})
export class ChartsRoutingModule {}
