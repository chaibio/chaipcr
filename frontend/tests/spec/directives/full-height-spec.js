(function() {
  'use strict'

  fdescribe('Minimum Height directive', function() {

    var windowHeight = 1000

    beforeEach(function() {
      module('ChaiBioTech', function($provide) {
        mockCommonServices($provide)
      })
      inject(function($injector) {
        this.$timeout = $injector.get('$timeout')
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
      this.directive = this.$compile(angular.element('<div full-height offset="' + this.offset + '"></div>'))(this.scope)

    })

    it('should set minimum height to element', function() {
      expect(this.directive.css('minHeight').replace('px', '') * 1).toBe(1000 - this.offset)
    })

    it('should reset on window.resize', function() {
      windowHeight = 2000
      this.$rootScope.$broadcast('window:resize')
      this.$timeout.flush()
      expect(this.directive.css('minHeight').replace('px', '') * 1).toBe(2000 - this.offset)
    })

    it('should force height', function() {
      windowHeight = 2000
      this.directive = this.$compile(angular.element('<div full-height force="true"></div>'))(this.$rootScope.$new())
      expect(this.directive.height()).toBe(2000)
    })

    fdescribe('When doc param is true', function() {

      beforeEach(function() {
        this.compiled = this.$compile(angular.element('<div style="height: 100%;"><div id="directive" full-height doc="true"></div></div>'))(this.$rootScope.$new())
      })

      it('should use largest node height if doc param is true', function() {
        expect(this.compiled.find('#directive').css('min-height')).toBe(this.WindowWrapper.documentHeight() + 'px')
      })

      it('should reset on window.resize', function() {
        windowHeight = 100
        this.$rootScope.$broadcast('window:resize')
        expect(this.compiled.find('#directive').attr('style')).toBeFalsy()
        this.$timeout.flush()
        expect(this.compiled.find('#directive').css('min-height')).toBe(this.WindowWrapper.documentHeight() + 'px')
      })

    })


  })

})();
