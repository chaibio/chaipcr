(function () {

  'use strict';

  describe('IsTouchScreen Service', function () {

    var touchScreenSize = {
      width: 800,
      height: 600
    }

    var mockWindowWrapperService = {
      initEventHandlers: function () {},
      width: function () {
        return touchScreenSize.width
      },
      height: function () {
        return touchScreenSize.height
      }
    }

    beforeEach(function () {

      spyOn(window.location, 'assign').and.returnValue(true)

      module('ChaiBioTech', function ($provide) {
        //mockCommonServices($provide)
        $provide.value('WindowWrapper', mockWindowWrapperService)
      })

      inject(function ($injector) {
        this.$window = $injector.get('$window')
        this.WindowWrapper = $injector.get('WindowWrapper')
        this.IsTouchScreen = $injector.get('IsTouchScreen')
      })

    })

    it('should redirect to touchscreen app base on window size', function () {
      var w = this.$window
      var api_port = 4444

      this.IsTouchScreen()
      expect(w.location.assign).toHaveBeenCalledWith(w.location.protocol + '//' + w.location.hostname + ':' + api_port)

    })

  })

})();
