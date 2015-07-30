window.ChaiBioTech.ngApp

.service 'Experiment', [
  '$resource'
  '$http'
  'host'
  ($resource, $http, host) ->

    self = $resource('/experiments/:id', {id: '@id'}, {
      update:
        method: 'PUT'
    })

    self.getTemperatureData = (expId, opts = {}) ->

      opts.starttime = opts.starttime || 0
      opts.resolution = opts.resolution || 1000

      $http.get "/experiments/#{expId}/temperature_data",
        params:
          starttime: opts.starttime
          endtime: opts.endtime
          resolution: opts.resolution

    self.duplicate = (expId, data) ->
      $http.post "/experiments/#{expId}/copy", data

    self.startExperiment = (expId) ->
      $http.post "#{host}:8000/control/start", {experimentId: expId}

    self.stopExperiment = ->
      $http.post "#{host}:8000/control/stop"

    return self

]