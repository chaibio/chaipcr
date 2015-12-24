window.ChaiBioTech.ngApp.directive('supportAccess', [
  'supportAccessService',
  '$uibModal',

  function(supportAccessService, $uibModal) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/settings/support-access.html',

      link: function(scope, elem, attr) {

        $(elem).find(".button").click(function() {
          scope.getAccess();
        });

        scope.getAccess = function() {

          supportAccessService.accessSupport()
          .then(function(data) { // success
            scope.message = "We have successfully enabled support access. Thank you.";
            scope.getMessage();
          }, function(data) { // Failure
            scope.message = "We could not enable support access at this moment. Please try again later.";
            scope.getMessage();
          });
        };

        scope.getMessage = function() {

          scope.modal = $uibModal.open({
            scope: scope,
            templateUrl: 'app/views/support-access-result.html',
            windowClass: 'small-modal'
            // This is tricky , we used it here so that,
            //Custom size of this modal doesn't change any other modal in use
          });
        };
      }
    };
  }
]);
