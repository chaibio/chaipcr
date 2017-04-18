angular.module('dynexp', [
  'dynexp.optical_cal',
  'dynexp.dual_channel_optical_cal_v2',
])
.value('host', 'http://' + window.location.hostname)
.run(['dynexpStatusService', function(Status) {
  Status.startSync();
}]);