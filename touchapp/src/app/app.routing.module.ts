import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { SharedModule } from './shared/shared.module';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { DashboardAuthGuard } from './components/dashboard/dashboard.auth-guard';
import { HomeComponent } from './components/dashboard/home/home.component';
import { SettingComponent } from './components/setting/setting.component';
import { LoginComponent } from './components/login/login.component';
import { LoginRouteGuard } from './components/login/login.route.guard';
import { ChartsComponent } from './components/dashboard/charts/charts.component';
import { AmplificationComponent } from './components/dashboard/charts/amplification/amplification.component';
import { SettingHomeComponent } from './components/setting/home/home.component';
import { ManageUsersComponent } from './components/setting/users/users.component';
import { NewUserComponent } from './components/setting/new-user/new-user.component';
import { EditUserComponent } from './components/setting/edit-user/edit-user.component';

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
    path: 'setting',
    component: SettingComponent,
    canActivate: [DashboardAuthGuard],
    canActivateChild: [DashboardAuthGuard],
    children: [
      {
        path: '',
        component: SettingHomeComponent,
      },
      {
        path: 'users',
        component: ManageUsersComponent,
      },
      {
        path: 'users/new',
        component: NewUserComponent,
      },
      {
        path: 'users/:user_id',
        component: EditUserComponent,
      },
    ]
  },
  // {
  //   path: 'login',
  //   component: LoginComponent,
  //   canActivate: [LoginRouteGuard]
  // }
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
