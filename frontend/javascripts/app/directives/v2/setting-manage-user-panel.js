 window.ChaiBioTech.ngApp.directive('manageUserPanel', [
   function() {
     return {
        restrict: 'E',
        templateUrl: 'app/views/settings/v2/manage-user-panel.html',
        replace: true,
        bindToController: true,
        controller: 'SettingManageUserPanelCtrl',
        scope: {
          cssClass: '@class',
          selected_user: '=selected'
        }
     };
   }
 ]);
