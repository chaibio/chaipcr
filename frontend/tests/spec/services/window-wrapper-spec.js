(function() {
  'use strict'

  describe('WindowWrapper Service', function() {

    describe('On Mobile', function() {

      var windowMock = {
        navigator: {
          userAgent: 'Mozilla/5.0 (iPad; CPU OS 8_0_2 like Mac OS X)\
          AppleWebKit/60.1.4 (KHTML, like Gecko) Version/8.0\
          Mobile/12A405 Safari/600.1.4'
        },
        innerWidth: 200
      }

      beforeEach(function() {
        module('ChaiBioTech', function($provide) {
          mockCommonServices($provide)
          $provide.value('$window', windowMock)
        })

        inject(function($injector) {
          this.WindowWrapper = $injector.get('WindowWrapper')
        })
      })

      it('should return width of mobile browser window', function() {
        expect(this.WindowWrapper.width()).toEqual(windowMock.innerWidth)
      })

    })

    describe('On Desktop', function() {

      beforeEach(function() {
        module('ChaiBioTech', function($provide) {
          mockCommonServices($provide)
        })

        inject(function($injector) {
          this.$rootScope = $injector.get('$rootScope')
          this.$window = $injector.get('$window')
          this.WindowWrapper = $injector.get('WindowWrapper')
        })
      })

      it('should return width of desktop browser window', function() {
        expect(this.WindowWrapper.width()).toEqual($(this.$window).width())
      })

      it('should return window height', function() {
        expect(this.WindowWrapper.height()).toBe(angular.element(this.$window).height())
      })

      it('should return document height', function() {
        angular.element('body').css({ margin: 0, padding: 0 }).append('<div style="height: 1234px"></div>')
        expect(this.WindowWrapper.documentHeight()).toBe(1234)
      })

      it('should broadcast keypressed:command event', function () {
        var charCodes = [224, 17, 91, 93] // https://stackoverflow.com/questions/3902635/how-does-one-capture-a-macs-command-key-via-javascript

        spyOn(this.$rootScope, '$apply').and.callFake(function(fn) {
          fn()
        })

        spyOn(this.$rootScope, '$broadcast')

        for (var i=0; i < charCodes.length; i++) {
          var code = charCodes[i]

          var e = jQuery.Event("keydown")
          e.which = code
          $(window.document.body).trigger(e)
          expect(this.$rootScope.$broadcast).toHaveBeenCalledWith('keypressed:command')

        }

      })

      it('should broadcast keyreleased:command event', function () {
        var charCodes = [224, 17, 91, 93] // https://stackoverflow.com/questions/3902635/how-does-one-capture-a-macs-command-key-via-javascript

        spyOn(this.$rootScope, '$apply').and.callFake(function(fn) {
          fn()
        })

        spyOn(this.$rootScope, '$broadcast')

        for (var i=0; i < charCodes.length; i++) {
          var code = charCodes[i]

          var e = jQuery.Event("keyup")
          e.which = code
          $(window.document.body).trigger(e)
          expect(this.$rootScope.$broadcast).toHaveBeenCalledWith('keyreleased:command')

        }

      })

      it('should broadcast window:resize event', function() {
        spyOn(this.$rootScope, '$apply').and.callFake(function(fn) {
          fn()
        })
        spyOn(this.$rootScope, '$broadcast')
        angular.element(this.$window).triggerHandler('resize')
        expect(this.$rootScope.$broadcast).toHaveBeenCalledWith('window:resize')
        expect(this.$rootScope.$broadcast).toHaveBeenCalledTimes(1)
      })

      it('should broadcast window:mousedown event', function() {
        var e = {
          type: 'mousedown',
          clientX: 0,
          clientY: 0
        }
        spyOn(this.$rootScope, '$apply').and.callFake(function(fn) {
          fn()
        })
        spyOn(this.$rootScope, '$broadcast').and.callFake(function(event, data) {
          expect(event).toBe('window:mousedown')
          expect(data.clientX).toBe(e.clientX)
          expect(data.clientY).toBe(e.clientY)
        })
        angular.element(this.$window).triggerHandler(e)
        expect(this.$rootScope.$broadcast).toHaveBeenCalledTimes(1)
      })

      it('should broadcast window:mouseup event', function() {
        var e = {
          type: 'mouseup',
          clientX: 0,
          clientY: 0
        }
        spyOn(this.$rootScope, '$apply').and.callFake(function(fn) {
          fn()
        })
        spyOn(this.$rootScope, '$broadcast').and.callFake(function(event, data) {
          expect(event).toBe('window:mouseup')
          expect(data.clientX).toBe(e.clientX)
          expect(data.clientY).toBe(e.clientY)
        })
        angular.element(this.$window).triggerHandler(e)
        expect(this.$rootScope.$broadcast).toHaveBeenCalledTimes(1)
      })

      it('should broadcast window:mousemove event', function() {
        var e = {
          type: 'mousemove',
          clientX: 0,
          clientY: 0
        }
        spyOn(this.$rootScope, '$apply').and.callFake(function(fn) {
          fn()
        })
        spyOn(this.$rootScope, '$broadcast').and.callFake(function(event, data) {
          expect(event).toBe('window:mousemove')
          expect(data.clientX).toBe(e.clientX)
          expect(data.clientY).toBe(e.clientY)
        })
        angular.element(this.$window).triggerHandler(e)
        expect(this.$rootScope.$broadcast).toHaveBeenCalledTimes(1)
      })

    })

    afterEach(function () {
      angular.element(this.$window).off()
      angular.element(document).off()
    })

  })

})();
