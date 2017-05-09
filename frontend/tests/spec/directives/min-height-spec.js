(function() {
  'use strict'

  describe('Minimum Height directive', function() {

    beforeEach(function() {
      module('ChaiBioTech', function($provide) {
        mockCommonServices($provide)
      })
      inject(function($injector) {
        this.$rootScope = $injector.get('$rootScope')
        this.$compile = $injector.get('$compile')
        this.WindowWrapper = $injector.get('WindowWrapper')
        this.$window = $injector.get('$window')
        this.scope = this.$rootScope.$new()
        this.offset = 60
      })

      spyOn(this.WindowWrapper, 'height').and.returnValue(1000)
      this.directive = this.$compile(angular.element('<div min-height offset="' + this.offset + '"></div>'))(this.scope)

    })

    it('should set minimum height to element', function() {
      expect(this.directive.css('minHeight').replace('px', '') * 1).toBe(1000 - this.offset)
    })


  })

})();
