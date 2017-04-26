(function() {

  'use strict'

  var userMock = {
    id: 1,
    name: 'Test'
  }

  var experimentsMock = [{
    "experiment": {
      "id": 11,
      "name": "Calibration curve - 671",
      "time_valid": true,
      "started_at": "2016-12-15T23:49:16.000Z",
      "completed_at": "2016-12-16T01:04:04.000Z",
      "completion_status": "success",
      "completion_message": "",
      "created_at": "2016-12-15T23:45:15.000Z",
      "type": "user"
    }
  }]

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
    this.$remove = function(fn) {
      fn()
    }
  }
  ExperimentServiceMock.query = function(fn) {
    fn(experimentsMock)
  }


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

  var uibModalMock = {
    open: function () {}
  }

  describe('HomeCtrl', function() {

    beforeEach(function() {
      module('ChaiBioTech', function($provide) {
        $provide.value('User', new UserServiceMock());
        $provide.value('Experiment', ExperimentServiceMock);
        $provide.value('Status', StatusMock);
        $provide.value('NetworkSettingsService', NetworkSettingsServiceMock);
        $provide.value('$uibModal', uibModalMock);
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

    it('should fetch all experiments', function() {
      expect(this.scope.experiments).toEqual(experimentsMock)
    })

    it('should open test kit modal', function() {
      spyOn(uibModalMock, 'open')
      this.ctrl.newTestKit()
      expect(uibModalMock.open).toHaveBeenCalled()
    })

    it('should delete experiment', function () {
      this.ctrl.deleteExperiment(experimentsMock[0])
      expect(this.scope.experiments.length).toBe(0)
    })

  })

})();
