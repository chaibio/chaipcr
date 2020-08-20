 window.ChaiBioTech.ngApp.directive('maintenancePanel', [
   function() {
     return {
        restrict: 'E',
        templateUrl: 'app/views/settings/v2/maintenance-panel.html',
        replace: true,
        bindToController: true,
        controller: 'SettingMaintenancePanelCtrl',
        scope: {
          cssClass: '@class'
        }
     };
   }
 ]);
