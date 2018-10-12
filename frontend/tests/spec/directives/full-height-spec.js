(function() {
  'use strict'

  describe('Full Height directive', function() {

    var windowHeight = 0
    var windowDocHeight = 0

    beforeEach(function() {

      windowHeight = 1000
      windowDocHeight = 1000

      module('ChaiBioTech', function($provide) {
        mockCommonServices($provide)
      })

      inject(function($injector) {
        alert('injoectr')
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

      spyOn(this.WindowWrapper, 'documentHeight').and.callFake(function() {
        return windowDocHeight
      })

      this.directive = this.$compile(angular.element('<div full-height offset="' + this.offset + '"></div>'))(this.scope)
      this.$timeout.flush()
    })

    it('should add full-height class to element', function() {
      expect(this.directive.hasClass('full-height')).toBe(true)
    })

    it('should set minimum height to element', function() {
      expect(this.directive.css('minHeight').replace('px', '') * 1).toBe(1000 - this.offset)
    })

    it('should reset on window.resize', function() {
      var oldHeight = windowHeight
      windowHeight = 2000
      this.$rootScope.$broadcast('window:resize')
      this.$rootScope.$broadcast('window:resize')
      expect(this.directive.css('overflow')).toBe('hidden')
      expect(this.directive.css('height')).toBe('0px')
      expect(this.directive.css('minHeight').replace('px', '') * 1).toBe(windowHeight - this.offset)
      this.$timeout.flush()
      expect(this.directive.css('minHeight').replace('px', '') * 1).toBe(2000 - this.offset)
    })

    it('should force height', function() {
      windowHeight = 2000
      this.directive = this.$compile(angular.element('<div full-height force="true"></div>'))(this.$rootScope.$new())
      this.$timeout.flush()
      expect(this.directive.height()).toBe(2000)
    })

    it('should have min height', function() {
      windowHeight = 2000
      this.directive = this.$compile(angular.element('<div full-height min="5000"></div>'))(this.$rootScope.$new())
      expect(this.directive.css('min-height')).toBe('5000px')
      this.$timeout.flush()
      expect(this.directive.css('min-height')).toBe('5000px')
    })

    describe('When doc param is true', function() {

      beforeEach(function() {
        this.scope = this.$rootScope.$new()
        this.compiled = this.$compile(angular.element('<div style="height: 100%;"><div id="directive" full-height doc="true"></div></div>'))(this.scope)
        this.directive = this.compiled.find('#directive')
        this.$timeout.flush()
      })

      it('should use largest node height if doc param is true', function() {
        expect(this.directive.css('min-height')).toBe(this.WindowWrapper.documentHeight() + 'px')
      })

      it('should reset on window.resize', function() {
        windowDocHeight = 100
        this.$rootScope.$broadcast('window:resize')
        this.$rootScope.$broadcast('window:resize')
        expect(this.directive.css('overflow')).toBe('hidden')
        expect(this.directive.css('height')).toBe('0px')
        expect(this.directive.css('min-height')).toBe(this.WindowWrapper.documentHeight() + 'px')
        this.$timeout.flush()
        expect(this.directive.css('overflow')).toBe('')
        expect(this.compiled.find('#directive').css('min-height')).toBe(this.WindowWrapper.documentHeight() + 'px')
      })

    })

    describe('When parent param is true', function() {

      beforeEach(function() {
        this.compiled = this.$compile(angular.element('<div style="height: 1234px"><div id="directive" full-height parent="true"></div></div>'))(this.$rootScope.$new())
        this.$timeout.flush()
        this.directive = this.compiled.find('#directive')
      })

      it('should use parent element height', function() {
        expect(this.directive.css('min-height')).toBe('1234px')
      })

    })

  })

})();
