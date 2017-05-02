(function() {
  'use strict'

  describe("Testing PikaController", function() {

    beforeEach(module('ChaiBioTech', function($provide) {
      $provide.value('dynexpExperimentService', ExperimentServiceMock)
    }));

    beforeEach(inject(function(_$controller_, _$rootScope_, $httpBackend, $stateParams, $q) {
      this.$controller = _$controller_;
      this.$rootScope = _$rootScope_;
      this.$stateParams = $stateParams;

      this.$scope = this.$rootScope.$new();

      this.$stateParams.id = 10;
      //$scope.experiment.id =10;

      this.PikaTestCtrl = this.$controller('PikaTestCtrl', { $scope: this.$scope });
      spyOn(this.$scope, 'goToResults');
    }));

    it("should have PikaController", function() {
      expect(this.PikaTestCtrl).toBeDefined();
    });

    it("should call getResults", function() {
      this.$scope.getResults();
      expect(this.$scope.testFl).toBe(true);
    });

  });

})();
