window.App.controller 'SettingsCtrl', [
  '$scope'
  'Device'
  ($scope, Device) ->

    Device.getVersion().then (resp) ->
      console.log resp

]