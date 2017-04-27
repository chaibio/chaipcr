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


var StatusServiceMock = {
  fetch: function () {
    return {
      then: function(fn) {}
    }
  },
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
  open: function() {}
}
