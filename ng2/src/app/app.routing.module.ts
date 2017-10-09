import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { SharedModule } from './shared/shared.module';
import { DashboardComponent } from './dashboard/dashboard.component';
import { LoginComponent } from './login/login.component';
import { LoginRouteGuard } from './login/login.route.guard';

const appRoutes: Routes = [
  {
    path: '',
    loadChildren: './dashboard/dashboard.module#DashboardModule'
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
  exports: [
    SharedModule,
    RouterModule,
  ],
  providers: [
    LoginRouteGuard
  ]
})
export class AppRoutesModule { }
