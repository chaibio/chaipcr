(function() {
  'use strict'

  describe('Testing Scrollbar Directive', function() {

    beforeEach(function() {

      module('ChaiBioTech', function($provide) {
        mockCommonServices($provide)
      })

      inject(function($injector) {
        this.TextSelection = $injector.get('TextSelection')
        this.$timeout = $injector.get('$timeout')
        this.$compile = $injector.get('$compile')
        this.$rootScope = $injector.get('$rootScope')
        this.scope = this.$rootScope.$new()
        this.scope.scrollbar = {
          value: 0.5,
          width: 0.5
        }
      })

      var elem = angular.element('<div style="width:100px;"><scrollbar id="scrollbar" ng-model="scrollbar"></scrollbar></div>')
      this.compiled = this.$compile(elem)(this.scope)
      this.scope.$digest()
      this.$timeout.flush()

      this.directive = this.compiled.find('#scrollbar')
      this.svg = this.directive.find('svg').eq(0)
      this.background = this.directive.find('rect').eq(0)
      this.handle = this.directive.find('rect').eq(1)

    })

    it('should have svg element', function() {
      var svg = this.svg
      expect(svg).toBeDefined()
      expect(svg.attr('width')).toBe('100')
      expect(svg.attr('height')).toBe('5')
    })

    it('should have rect element as background', function() {
      var rect = this.directive.find('rect').eq(0)
      expect(rect).toBeDefined()
      expect(rect.attr('width')).toBe('100')
      expect(rect.attr('height')).toBe('5')
      expect(rect.attr('fill')).toBe('#ccc')
      expect(rect.attr('rx')).toBe('2')
      expect(rect.attr('ry')).toBe('2')
    })

    it('should have rect element as handle', function() {
      var rect = this.directive.find('rect').eq(1)
      expect(rect).toBeDefined()
      expect(rect.attr('width')).toBe('50')
      expect(rect.attr('height')).toBe('5')
      expect(rect.attr('fill')).toBe('#555')
      expect(rect.attr('rx')).toBe('2')
      expect(rect.attr('ry')).toBe('2')
      expect(rect.attr('x')).toBe('25')
    })

    it('should resize', function() {
      var self = this
      this.handle.attr('width', 50)
      this.scope.scrollbar.value = 0.25
      this.scope.scrollbar.width = 0.5
      this.scope.$digest()
      this.compiled.css({ width: 200 })
      this.directive.css({ width: 200 })
      this.$rootScope.$broadcast('window:resize')
      this.$rootScope.$broadcast('window:resize')
      expect(this.svg.attr('width')).toBe('0')
      expect(this.background.attr('width')).toBe('0')
      expect(this.handle.attr('width')).toBe('0')
      this.$timeout.flush()
      expect(this.svg.attr('width')).toBe('200')
      expect(this.background.attr('width')).toBe('200')
      expect(this.handle.attr('width')).toBe('100')
      expect(this.handle.attr('x')).toBe('25')
    })

    describe('Scrollbar handle', function() {

      it('should have min scroll handle width', function() {
        this.scope.scrollbar.value = 0
        this.scope.scrollbar.width = 0
        this.scope.$digest()
        expect(this.handle.attr('width')).toBe('15')
      })

      it('should move', function() {
        spyOn(this.TextSelection, 'disable').and.callThrough()
        spyOn(this.TextSelection, 'enable').and.callThrough()
        var e = {
          type: 'mousedown',
          pageX: 0
        }
        expect(this.TextSelection.disable).not.toHaveBeenCalled()
        this.handle.triggerHandler(e)
        expect(this.TextSelection.disable).toHaveBeenCalled()
        this.$rootScope.$broadcast('window:mousemove', {
          pageX: 25
        })
        expect(this.handle.attr('x')).toEqual('50')
        expect(this.TextSelection.enable).not.toHaveBeenCalled()
        this.$rootScope.$broadcast('window:mouseup')
        expect(this.TextSelection.enable).toHaveBeenCalled()
        expect(this.scope.scrollbar.value).toBe(1)
        expect(this.scope.scrollbar.width).toBe(0.5)
      })

      it('should not go beyond its width when moving right', function() {
        var e = {
          type: 'mousedown',
          pageX: 0
        }
        this.handle.triggerHandler(e)
        this.$rootScope.$broadcast('window:mousemove', {
          pageX: 50
        })
        expect(this.handle.attr('x')).toEqual('50')
        expect(this.scope.scrollbar.value).toBe(1.5)
      })

      it('should not go beyond its width when moving left', function() {
        var e = {
          type: 'mousedown',
          pageX: 0
        }
        this.handle.attr('width', 50)
        this.handle.triggerHandler(e)
        this.$rootScope.$broadcast('window:mousemove', {
          pageX: -50
        })
        expect(this.handle.attr('x')).toEqual('0')
        expect(this.scope.scrollbar.value).toBe(-0.5)
      })

      it('should turn cursor to pointer', function() {
        expect(this.directive.css('cursor')).toBe('pointer')
      })

    })

  })


})();
