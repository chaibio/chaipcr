window.ChaiBioTech.ngApp

.service 'Experiment', [
  '$resource'
  '$http'
  '$q'
  'host'
  ($resource, $http, $q, host) ->

    currentExperiment = null
    ques = {}

    self = $resource('/experiments/:id', {id: '@id'}, {
      'update':
        method: 'PUT'
    })

    self.get = (obj) ->
      ques["exp_#{obj.id}"] = ques["exp_#{obj.id}"] || []
      deferred = $q.defer()
      ques["exp_#{obj.id}"].push deferred

      return deferred.promise if ques["exp_#{obj.id}"].length > 1 #there is already pending request for this experiment, wait for it

      $http.get("/experiments/#{obj.id}")
      .then (resp) ->
        for def in ques["exp_#{obj.id}"] by 1
          def.resolve resp.data
      .catch (resp) ->
        for def in ques["exp_#{obj.id}"] by 1
          def.reject resp

      .finally ->
        delete ques["exp_#{obj.id}"]

      return deferred.promise

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
      $http.get("/experiments/#{expId}/amplification_data")

    self.getMeltCurveData = (expId) ->
      $http.get("/experiments/#{expId}/melt_curve_data")

    self.duplicate = (expId, data) ->
      $http.post "/experiments/#{expId}/copy", data

    self.startExperiment = (expId) ->
      $http.post "#{host}:8000/control/start", {experiment_id: expId}

    self.stopExperiment = ->
      $http.post "#{host}:8000/control/stop"

    self.resumeExperiment = ->
      $http.post "#{host}:8000/control/resume"

    self.getExperimentDuration = (exp) ->
      start = new Date(exp.started_at)
      end = new Date(exp.completed_at)
      # console.log end
      (end.getTime() - start.getTime())/1000;
      # 10
      # end.subtract(start).seconds()

    self.truncateName = (name, truncate_length) ->
      NAME_LENGTH = parseInt(truncate_length)
      return if !name
      return name if name.length <= NAME_LENGTH
      return name.substring(0, NAME_LENGTH-2)+'...'

    return self

]