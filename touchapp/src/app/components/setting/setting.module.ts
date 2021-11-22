import { NgModule } from '@angular/core'

import { RouterModule } from '@angular/router';
import { SharedModule } from '../../shared/shared.module';
import { SettingComponent } from './setting.component'
import { SettingNavComponent } from './setting-nav/setting-nav.component'
import { SettingBreadcrumbsComponent } from './breadcrumbs/breadcrumbs.component'
import { SettingHomeComponent } from './home/home.component'
import { ManageUsersComponent } from './users/users.component'
import { NewUserComponent } from './new-user/new-user.component'
import { EditUserComponent } from './edit-user/edit-user.component'
import { EditUserGuard } from './edit-user/edit-user.guard'
import { NewUserGuard } from './new-user/new-user.guard'

const components = [
  SettingComponent,
  SettingNavComponent,
  SettingBreadcrumbsComponent,
  SettingHomeComponent,
  ManageUsersComponent,
  NewUserComponent,
  EditUserComponent,
]

@NgModule({
  imports: [
    RouterModule,
    SharedModule
  ],
  declarations: components,
  exports: [
    ...components
  ],
  providers: [
    EditUserGuard,
    NewUserGuard,
  ]  
})

export class SettingModule {}
