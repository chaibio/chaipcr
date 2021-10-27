import { NgModule } from '@angular/core'

import { RouterModule } from '@angular/router';
import { SharedModule } from '../../shared/shared.module';
import { SettingComponent } from './setting.component'
import { SettingNavComponent } from './setting-nav/setting-nav.component'
import { SettingBreadcrumbsComponent } from './breadcrumbs/breadcrumbs.component'
import { SettingHomeComponent } from './home/home.component'
import { ManageUsersComponent } from './users/users.component'
import { NewUserComponent } from './new-user/new-user.component'

const components = [
  SettingComponent,
  SettingNavComponent,
  SettingBreadcrumbsComponent,
  SettingHomeComponent,
  ManageUsersComponent,
  NewUserComponent,
]

@NgModule({
  imports: [
    RouterModule,
    SharedModule
  ],
  declarations: components,
  exports: [
    ...components
  ]
})

export class SettingModule {}
