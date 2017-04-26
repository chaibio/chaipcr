(function() {

  'use strict'

  var userMock = {
    id: 1,
    name: 'Test'
  }

  function UserServiceMock() {
    this.getCurrent = function() {
      return {
        then: function(fn) {
          var res = {
            data: {
              user: userMock
            }
          }
          fn(res)
        }
      }
    }
  }

  function ExperimentServiceMock() {
    this.$remove = function() {}
  }
  ExperimentServiceMock.query = function() {}


  var StatusMock = {
    getData: function() {},
    startSync: function() {},
    startUpdateSync: function() {}
  }

  var NetworkSettingsServiceMock = {
    getWifiNetworks: function() {},
    lanLookup: function() {},
    getReady: function() {},
    getSettings: function() {}
  }

  describe('HomeCtrl', function() {

    beforeEach(function() {
      module('ChaiBioTech', function($provide) {
        $provide.value('User', new UserServiceMock());
        $provide.value('Experiment', ExperimentServiceMock);
        $provide.value('Status', StatusMock);
        $provide.value('NetworkSettingsService', NetworkSettingsServiceMock);
      })

      inject(function($injector) {
        this.controller = $injector.get('$controller')
        this.rootScope = $injector.get('$rootScope')
        this.scope = this.rootScope.$new()
        this.ctrl = this.controller('HomeCtrl', {
          '$scope': this.scope
        })
      })
    })

    it('should have current user', function() {
      expect(this.scope.user).toEqual(userMock)
    })

  })

})();
