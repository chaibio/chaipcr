 window.ChaiBioTech.ngApp.directive('updatePanel', [
   function() {
     return {
        restrict: 'E',
        templateUrl: 'app/views/settings/v2/update-panel.html',
        replace: true,
        bindToController: true,
        controller: 'SettingUpdatePanelCtrl',
        scope: {
          cssClass: '@class'
        }
     };
   }
 ]);
