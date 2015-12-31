window.ChaiBioTech.ngApp.service('userFormErrors', [
  function() {
    // Incase more user side errors has to add, Add it here and bring this service.
    // Right now we have only email error , so just resolve in the controller itself
    this.passErr = "bingo";
    this.handleError = function($scope, problem) {
      
      for(var errKey in problem.errors) {
        console.log(errKey);
        if(errKey === 'email') {
          $scope.emailAlreadtTaken = true;
        }
        break;
      }
    };
  }
]);
