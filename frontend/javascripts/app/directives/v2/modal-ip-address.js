 window.ChaiBioTech.ngApp.directive('modalIpAddress', [
   function() {
     return {
       restric: 'A',
       templateUrl: 'app/views/directives/v2/modal-ip-address.html',
       replace: true,
       scope: {
         ip: '=value',
         caption: '@',
         error: '=',
         field: '@'
       },
       link: function($scope, elem, attr) {
         if($scope.ip) {
           $scope.splittedIP = $scope.ip.split('.');
           angular.element('.ip-field').blur(function(evt) {
             $scope.ip = $scope.splittedIP.join('.');
           });
         }
       }
     };
   }
 ]);
