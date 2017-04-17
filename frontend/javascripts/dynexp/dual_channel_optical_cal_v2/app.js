angular.module('dynexp.dual_channel_optical_cal_v2', [
  'ui.router',
  'ngResource',
  'http-auth-interceptor',
  'angularMoment',
  'ui.bootstrap',
  'dynexp.libs',
])

.value('host', 'http://' + window.location.hostname)

.run(['dynexpStatusService', function(Status) {
  Status.startSync();
}]);
