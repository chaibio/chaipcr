window.ChaiBioTech.ngApp.directive('supportAccess', [

  function() {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/settings/support-access.html',

      link: function(scope, elem, attr) {
        //console.log("");
      }
    };
  }
]);
