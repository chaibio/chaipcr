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

function ExperimentServiceMock() {
  this.$remove = function(fn) {
    if (fn) fn()
  }
}

ExperimentServiceMock.query = function(fn) {
  fn(experimentsMock)
}

ExperimentServiceMock.delete = function() {}
