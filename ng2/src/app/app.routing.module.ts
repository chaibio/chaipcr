import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { SharedModule } from './shared/shared.module';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { DashboardAuthGuard } from './components/dashboard/dashboard.auth-guard';
import { HomeComponent } from './components/dashboard/home/home.component';
import { LoginComponent } from './components/login/login.component';
import { LoginRouteGuard } from './components/login/login.route.guard';
import { ChartsComponent } from './components/dashboard/charts/charts.component';
import { AmplificationComponent } from './components/dashboard/charts/amplification/amplification.component';

const appRoutes: Routes = [
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
      {
        path: 'charts/exp/:id/amplification',
        component: ChartsComponent,
        children: [
          {
            path: '',
            component: AmplificationComponent
          }
        ]
      }
    ]
  },
  {
    path: 'login',
    component: LoginComponent,
    canActivate: [LoginRouteGuard]
  }
];


@NgModule({
  declarations: [
    LoginComponent
  ],
  imports: [
    SharedModule,
    RouterModule.forRoot(appRoutes),
  ],
  providers: [
    LoginRouteGuard
  ],
  exports: [
    RouterModule,
  ]
  
})
export class AppRoutesModule { }
