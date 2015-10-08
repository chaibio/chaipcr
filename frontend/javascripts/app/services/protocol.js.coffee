window.ChaiBioTech.ngApp.service 'Protocol', [
  '$http'
  ($http) ->

    @update = (data) ->
      $http.put "/protocols/#{data.id}", data

    return
]