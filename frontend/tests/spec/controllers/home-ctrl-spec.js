(function() {

  'use strict'

  describe('Testing HomeCtrl', function() {

    beforeEach(function() {
      module('ChaiBioTech', function($provide) {
        $provide.value('User', new UserServiceMock());
        $provide.value('Experiment', ExperimentServiceMock);
        $provide.value('Status', StatusServiceMock);
        $provide.value('NetworkSettingsService', NetworkSettingsServiceMock);
        $provide.value('$uibModal', uibModalMock);
      })

      inject(function($injector) {
        this.controller = $injector.get('$controller')
        this.rootScope = $injector.get('$rootScope')
        this.scope = this.rootScope.$new()
        this.ctrl = this.controller('HomeCtrl', {
          '$scope': this.scope
        })
      })
    })

    it('should have current user', function() {
      expect(this.scope.user).toEqual(userMock)
    })

    it('should fetch all experiments', function() {
      expect(this.scope.experiments).toEqual(experimentsMock)
    })

    it('should open test kit modal', function() {
      spyOn(uibModalMock, 'open')
      this.ctrl.newTestKit()
      expect(uibModalMock.open).toHaveBeenCalled()
    })

    it('should delete experiment', function () {
      this.ctrl.deleteExperiment(experimentsMock[0])
      expect(this.scope.experiments.length).toBe(0)
    })

  })

})();
