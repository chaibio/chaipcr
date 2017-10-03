(function () {
  'use strict'

  describe('Testing IsMobile Service', function () {

    var windowMock = {
      navigator: {
        userAgent: 'Mozilla/5.0 (iPad; CPU OS 8_0_2 like Mac OS X)\
        AppleWebKit/60.1.4 (KHTML, like Gecko) Version/8.0\
        Mobile/12A405 Safari/600.1.4'
      }
    }

    beforeEach(function () {
      module('ChaiBioTech', function($provide) {
        mockCommonServices($provide)
        $provide.value('$window', windowMock)
      })

      inject(function($injector) {
        this.$window = $injector.get('$window')
        this.IsMobile = $injector.get('IsMobile')
      })
    })

    it('detects ipad mini as mobile', function () {

      expect(this.IsMobile()).toBe(true)

    })

  })

})();
