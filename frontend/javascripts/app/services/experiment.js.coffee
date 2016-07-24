###
Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
For more information visit http://www.chaibio.com

Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
window.ChaiBioTech.ngApp

.service 'Experiment', [
  '$resource'
  '$http'
  '$q'
  'host'
  ($resource, $http, $q, host) ->

    currentExperiment = null
    ques = {}
    # getExpDeferred = null

    self = $resource('/experiments/:id', {id: '@id'}, {
      'update':
        method: 'PUT'
    })

    self.get = (obj) ->
      ques["exp_#{obj.id}"] = ques["exp_#{obj.id}"] || []
      deferred = $q.defer()
      ques["exp_#{obj.id}"].push deferred

      console.log 'que:'
      console.log ques["exp_#{obj.id}"]
      console.log 'end que:'

      if ques["exp_#{obj.id}"].length > 1 and ques["exp_#{obj.id}"].length < 5 #there is already pending request for this experiment, wait for it
        return deferred.promise
      else
        console.log 'getting experiment $http'
        promise = $http.get("/experiments/#{obj.id}")
        promise.then (resp) ->
          console.log '$http then'
          for def in ques["exp_#{obj.id}"] by 1
            def.resolve resp.data
          null
        promise.catch (resp) ->
          console.log '$http catch'
          for def in ques["exp_#{obj.id}"] by 1
            def.reject resp
          null

        promise.finally ->
          console.log '$http finally'
          delete ques["exp_#{obj.id}"]
          ques = angular.copy(ques)
          null

        return deferred.promise

    # self.get = (obj) ->
    #   console.log "getExpDeferred: #{getExpDeferred}"
    #   if getExpDeferred
    #     return getExpDeferred.promise
    #   else
    #     getExpDeferred = $q.defer()
    #     $http.get("/experiments/#{obj.id}")
    #     .then (resp) ->
    #       console.log "experiment loaded in experiment service !!!!"
    #       getExpDeferred.resolve resp.data
    #       getExpDeferred = null
    #     .catch (resp) ->
    #       getExpDeferred.reject resp
    #       getExpDeferred = null

    #     return getExpDeferred.promise


    self.setCurrentExperiment = (exp) ->
      currentExperiment = exp

    self.getCurrentExperiment = ->
      currentExperiment

    self.analyze = (id) ->
      console.log 'anayling ....'
      $http.get("/experiments/#{id}/analyze")

    tempLogsQues = []
    self.getTemperatureData = (expId, opts = {}) ->

      opts.starttime = opts.starttime || 0
      opts.resolution = opts.resolution || 1000
      deferred = $q.defer()
      tempLogsQues.push deferred
      return deferred.promise if fetchingTempLogs

      fetchingTempLogs = true
      promise = $http.get "/experiments/#{expId}/temperature_data",
        params:
          starttime: opts.starttime
          endtime: opts.endtime
          resolution: opts.resolution

      promise.then (resp) ->
        for def in tempLogsQues by 1
          def.resolve resp.data
      promise.catch (err) ->
        for def in tempLogsQues by 1
          def.reject err
      promise.finally ->
        fetchingTempLogs = false
        tempLogsQues = []

      return deferred.promise

    self.getAmplificationData = (expId) ->
      $http.get("/experiments/#{expId}/amplification_data")

    self.getMeltCurveData = (expId) ->
      $http.get("/experiments/#{expId}/melt_curve_data")
      # $http.get("/test_melt_curve_data.json")

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
      (end.getTime() - start.getTime())/1000;

    self.truncateName = (name, truncate_length) ->
      NAME_LENGTH = parseInt(truncate_length)
      return if !name
      return name if name.length <= NAME_LENGTH
      return name.substring(0, NAME_LENGTH-2)+'...'

    self.getMaxExperimentCycle = (exp) ->
      return if !exp
      stages = exp.protocol.stages || []
      cycles = []

      for stage in stages by 1
        cycles.push stage.stage.num_cycles

      Math.max.apply Math, cycles

    return self

]
