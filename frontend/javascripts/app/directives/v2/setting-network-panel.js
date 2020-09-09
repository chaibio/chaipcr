 window.ChaiBioTech.ngApp.directive('networkPanel', [
   function() {
     return {
        restrict: 'E',
        templateUrl: 'app/views/settings/v2/network-panel.html',
        replace: true,
        bindToController: true,
        controller: 'SettingNetworkPanelCtrl',
        scope: {
          cssClass: '@class'
        }
     };
   }
 ]);
