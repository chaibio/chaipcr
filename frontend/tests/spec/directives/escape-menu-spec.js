(function() {
  'use strict'

  describe("Here we check the hit escape button and left-menu disappear", function() {

    beforeEach(module("ChaiBioTech", function($provide) {
      mockCommonServices($provide)
    }));

    beforeEach(function() {
      inject(function($injector) {
        this.$rootScope = $injector.get('$rootScope')
        this.scope = this.$rootScope.$new()
        this.$compile = $injector.get('$compile')
        this.$window = $injector.get('$window')
      })

      var elem = angular.element('<p escape-menu ></p>');
      this.directive = this.$compile(elem)(this.scope);
      this.scope.$digest();
    });

    it("Should check the initial conf", function() {
      this.scope.registerEscape = false;
      this.scope.$digest();
      expect(this.scope.registerEscape).toBeFalsy();
    });

    it("Should check if hitting escape key $broadcast", function() {
      spyOn(this.$rootScope, "$broadcast");
      spyOn(this.scope, '$apply')
      this.scope.sideMenuOpen = true

      angular.element(this.$window).triggerHandler({
        type: 'keyup',
        keyCode: 27,
      });
      //Safari/Chrome makes the keyCode and charCode properties read-only,
      //so it is not possible to simulate specific keys when manually firing events.
      expect(this.$rootScope.$broadcast).toHaveBeenCalledWith('sidemenu:toggle');
      expect(this.scope.$apply).toHaveBeenCalled()
    });

  });

})();
