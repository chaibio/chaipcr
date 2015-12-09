window.App.service 'Device', [
  '$http'
  ($http) ->
    return new class Device

      getVersion: ->
        $http.get('/device')

]