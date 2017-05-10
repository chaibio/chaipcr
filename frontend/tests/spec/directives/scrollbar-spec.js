(function () {
  'use strict'

  describe('Testing Scrollbar Directive', function () {

    beforeEach(function () {

      module('ChaiBioTech', function ($provide) {
        mockCommonServices($provide)
        $provide.value('TextSelection', TextSelectionMockService)
      })

      inject(function ($injector) {
        this.$compile = $injector.get('$compile')
        this.$rootScope = $injector.get('$rootScope')
        this.scope = this.$rootScope.$new()
        this.scope.scrollbar = {
          value: null,
          width: null
        }
      })

      var elem = angular.element('<scrollbar ng-model="scrollbar" style="width: 100px"></scrollbar>')
      this.directive = this.$compile(elem)(this.scope)
      this.scope.$digest()

    })

    it('should have svg element', function () {
      var svg = this.directive.find('svg')
      expect(svg).toBeDefined()
      expect(svg.attr('width')).toBe('100')
      expect(svg.attr('height')).toBe('5')
    })

    it('should have rect element as background', function () {
      var rect = this.directive.find('rect').eq(0)
      expect(rect).toBeDefined()
      expect(rect.attr('width')).toBe('100')
      expect(rect.attr('height')).toBe('5')
      expect(rect.attr('fill')).toBe('#ccc')
      expect(rect.attr('rx')).toBe('2')
      expect(rect.attr('ry')).toBe('2')
    })

    it('should have rect element as handle', function () {
      var rect = this.directive.find('rect').eq(1)
      expect(rect).toBeDefined()
      expect(rect.attr('width')).toBe('100')
      expect(rect.attr('height')).toBe('5')
      expect(rect.attr('fill')).toBe('#555')
      expect(rect.attr('rx')).toBe('2')
      expect(rect.attr('ry')).toBe('2')
    })

    it('should have min scroll handle width', function () {
      this.scope.scrollbar.value = 0
      this.scope.scrollbar.width = 0
      this.scope.$digest()
      var handle = this.directive.find('rect').eq(1)
      expect(handle.attr('width')).toBe('15')
    })

    it('should move', function () {
      
    })

  })


})();