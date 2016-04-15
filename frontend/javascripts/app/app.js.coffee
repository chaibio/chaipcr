window.ChaiBioTech = window.ChaiBioTech || {};

window.App = window.ChaiBioTech.ngApp = angular.module 'ChaiBioTech', [
  'templates'
  'perfect_scrollbar'
  'ui.slider'
  'ui.bootstrap'
  'ui.router'
  'uiSwitch'
  'ngResource'
  'angularMoment'
  'n3-line-chart-v2'
  'focusOn'
  'http-auth-interceptor'
  'http-response-interceptor'
  'ngAnimate'
  'angular-ladda'
  'ellipsisAnimated'
  'ngFileUpload'
  'canvasApp'
  'ngWebworker'
]
#Please make sure to add module files in karma-files.js, so that tests work.
