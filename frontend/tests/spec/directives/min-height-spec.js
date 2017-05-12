(function() {
  'use strict'

  describe('Minimum Height directive', function() {

    var windowHeight = 1000

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

      spyOn(this.WindowWrapper, 'height').and.callFake(function() {
        return windowHeight
      })
      this.directive = this.$compile(angular.element('<div min-height offset="' + this.offset + '"></div>'))(this.scope)

    })

    it('should set minimum height to element', function() {
      expect(this.directive.css('minHeight').replace('px', '') * 1).toBe(1000 - this.offset)
    })

    it('should reset on window.resize', function() {
      windowHeight = 2000
      this.$rootScope.$broadcast('window:resize')
      this.scope.$digest()
      expect(this.directive.css('minHeight').replace('px', '') * 1).toBe(2000 - this.offset)
    })

    it('should force height', function() {
      windowHeight = 2000
      this.directive = this.$compile(angular.element('<div min-height force="true"></div>'))(this.$rootScope.$new())
      expect(this.directive.height()).toBe(2000)
    })

  })

})();
