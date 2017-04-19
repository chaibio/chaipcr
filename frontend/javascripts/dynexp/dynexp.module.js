angular.module('dynexp', [
  'dynexp.libs',
  'dynexp.optical_cal',
  'dynexp.dual_channel_optical_cal_v2',
  'dynexp.optical_test_dual_channel',
])
.value('host', 'http://' + window.location.hostname)
.run(['dynexpStatusService', function(Status) {
  Status.startSync();
}]);