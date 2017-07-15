// import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { RouterModule, Routes } from '@angular/router';

import { DashboardComponent } from './dashboard/dashboard.component';
import { LoginComponent } from './login/login.component';
import { LoginRouteGuard } from './login/login.route.guard';


const appRoutes: Routes = [
  {
    path: '',
    loadChildren: 'app/dashboard/dashboard.module#DashboardModule'
  },
  {
    path: 'login',
    component: LoginComponent,
    canActivate: [LoginRouteGuard]
  }
];


@NgModule({
  imports: [
    RouterModule.forRoot(appRoutes),
  ],
  exports: [
    RouterModule,
  ],
  providers: [
    LoginRouteGuard
  ]
})
export class AppRoutesModule { }