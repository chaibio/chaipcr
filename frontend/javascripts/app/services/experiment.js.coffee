window.ChaiBioTech.ngApp

.service 'Experiment', [
  '$resource'
  '$http'
  'host'
  ($resource, $http, host) ->

    currentExperiment = null

    self = $resource('/experiments/:id', {id: '@id'}, {
      'update':
        method: 'PUT'
    })

    self.setCurrentExperiment = (exp) ->
      currentExperiment = exp

    self.getCurrentExperiment = ->
      currentExperiment

    self.getTemperatureData = (expId, opts = {}) ->

      opts.starttime = opts.starttime || 0
      opts.resolution = opts.resolution || 1000

      $http.get "/experiments/#{expId}/temperature_data",
        params:
          starttime: opts.starttime
          endtime: opts.endtime
          resolution: opts.resolution

    self.getFluorescenceData = (expId) ->
      $http.get("/experiments/#{expId}/fluorescence_data")

    self.duplicate = (expId, data) ->
      $http.post "/experiments/#{expId}/copy", data

    self.startExperiment = (expId) ->
      $http.post "#{host}:8000/control/start", {experimentId: expId}

    self.stopExperiment = ->
      $http.post "#{host}:8000/control/stop"

    self.getExperimentDuration = (exp) ->
      start = new Date(exp.started_at)
      end = new Date(exp.completed_at)
      # console.log end
      (end.getTime() - start.getTime())/1000;
      # 10
      # end.subtract(start).seconds()

    return self

]