(function() {
  'use strict'

  fdescribe('Testing Auth Service', function() {

    beforeEach(function() {

      module('ChaiBioTech', function($provide) {
        $provide.value('Status', StatusServiceMock)
        $provide.value('NetworkSettingsService', NetworkSettingsServiceMock)
      })

      inject(function($injector) {
        this.$httpBackend = $injector.get('$httpBackend')
        this.AuthService = $injector.get('Auth')
        this.AuthTokenService = $injector.get('AuthToken')
        this.$window = $injector.get('$window')
        this.$cookies = $injector.get('$cookies')

        spyOn(this.$window.$.jStorage, 'deleteKey')
      })

    })

    it('should logout', function() {

      this.$httpBackend.expectPOST('/logout').respond(200)
      this.AuthService.logout()
      this.$httpBackend.flush()
      expect(this.$window.$.jStorage.get('authToken')).toBeFalsy()
      expect(this.$cookies.authentication_token).toBeFalsy()
    })

    describe('Testing AuthToken Service', function() {

      it('should append auth token from jStorage to url', function() {
        var url = 'http://localhost:8000/status'
        var configMock = {
          url: url
        }
        var token = 'this_is_fake_token'
        $.jStorage.set('authToken', token)
        var config = this.AuthTokenService.request(configMock)
        expect(config.url).toEqual(url + '?access_token=' + token)
      })

      it('should append auth token from cookie to url', function() {
        var url = 'http://localhost:8000/status'
        var configMock = {
          url: url
        }
        var token = 'this_is_fake_token'
        this.$cookies.authentication_token = token
        var config = this.AuthTokenService.request(configMock)
        expect(config.url).toEqual(url + '?access_token=' + token)
      })

      it('should append auth token from cookie to url with single query params', function() {
        var url = 'http://localhost:8000/status?x=x'
        var configMock = {
          url: url
        }
        var token = 'this_is_fake_token'
        this.$cookies.authentication_token = token
        var config = this.AuthTokenService.request(configMock)
        expect(config.url).toEqual(url + '&access_token=' + token)
      })

      it('should append auth token from cookie to url with multiple query params', function() {
        var url = 'http://localhost:8000/status?x=x&y=y'
        var configMock = {
          url: url
        }
        var token = 'this_is_fake_token'
        this.$cookies.authentication_token = token
        var config = this.AuthTokenService.request(configMock)
        expect(config.url).toEqual(url + '&access_token=' + token)
      })

    })

    afterEach(function() {
      this.$httpBackend.verifyNoOutstandingExpectation();
      this.$httpBackend.verifyNoOutstandingRequest();
    })

  })

})();
