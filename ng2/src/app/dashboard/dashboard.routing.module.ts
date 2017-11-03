import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { DashboardAuthGuard } from './dashboard.auth-guard';
import { DashboardComponent } from './dashboard.component';
import { HomeComponent } from './home/home.component';

const dashRoutes: Routes = [
  {
    path: '',
    component: DashboardComponent,
    canActivate: [DashboardAuthGuard],
    canActivateChild: [DashboardAuthGuard],
    children: [
      {
        path: '',
        component: HomeComponent,
      },
      //{
      //  path: 'charts',
      //  loadChildren: './charts/charts.module#ChartsModule'
      //}
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
    RouterModule.forChild(dashRoutes)
  ],
  exports: [
    RouterModule
  ],
  providers: [
    DashboardAuthGuard
  ]
})
export class DashboardRoutingModule {}
