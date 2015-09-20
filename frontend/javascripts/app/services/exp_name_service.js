window.ChaiBioTech.ngApp.service('expName', [
  '$rootScope',
  function($rootScope) {

    this.name = '';
    this.updateName = function(name) {
      this.name = name;
      $rootScope.$broadcast("expName:Updated");
    };
    return this;
  }
]);
