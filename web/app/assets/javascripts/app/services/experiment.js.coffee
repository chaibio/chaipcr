window.ChaiBioTech.ngApp

.service 'Experiment', [
  '$resource'
  '$http'
  ($resource, $http) ->

    self = $resource('/experiments/:id', {id: '@id'}, {
      update:
        method: 'PUT'
    })

    self.getTemperatureData = (expId, opts = {}) ->
      $http.get "/experiments/#{expId}/temperature_data",
        params:
          starttime: opts.starttime
          endtime: opts.endtime
          resolution: opts.resolution

    self

]