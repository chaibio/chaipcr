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

    self = $resource('/experiments/:id', {id: '@id'}, {
      'update':
        method: 'PUT'
    })

    self.get = (obj) ->
      ques["exp_#{obj.id}"] = ques["exp_#{obj.id}"] || []
      deferred = $q.defer()
      ques["exp_#{obj.id}"].push deferred

      if ques["exp_#{obj.id}"].length > 1 and ques["exp_#{obj.id}"].length < 5 #there is already pending request for this experiment, wait for it
        return deferred.promise
      else
        promise = $http.get("/experiments/#{obj.id}")
        promise.then (resp) ->
          if ques["exp_#{obj.id}"]
            for def in ques["exp_#{obj.id}"] by 1
              def.resolve resp.data
        promise.catch (resp) ->
          if ques["exp_#{obj.id}"]
            for def in ques["exp_#{obj.id}"] by 1
              def.reject resp

        promise.finally ->
          delete ques["exp_#{obj.id}"]
          ques = angular.copy(ques)

        return deferred.promise

    self.delete = (id) ->
      return $http.delete("/experiments/#{id}")

    self.setCurrentExperiment = (exp) ->
      currentExperiment = exp

    self.getCurrentExperiment = ->
      currentExperiment

    self.analyze = (id) ->
      $http.get("/experiments/#{id}/analyze")

    self.getWells = (id) ->
      $http.get("/experiments/" + id + "/wells")

    self.updateWell = (id,well_num,well_data) ->
      $http.put "/experiments/" + id + "/wells/" + well_num, well : well_data

    self.getAmplificationOptions = (id) ->
      $http.get("/experiments/" + id + "/amplification_option")

    self.updateAmplificationOptions = (id,amplificationData) ->
      $http.put "experiments/" + id + "/amplification_option/", amplification_option : amplificationData

    tempLogsQues = []
    self.getTemperatureData = (expId, opts = {}) ->

      opts.starttime = opts.starttime || 0
      opts.resolution = opts.resolution || 1000
      deferred = $q.defer()
      tempLogsQues.push deferred
      return deferred.promise if fetchingTempLogs

      fetchingTempLogs = true
      promise = $http.get "/experiments/#{expId}/temperature_data",
      # promise = $http.get "/temperature_data.json",
        params:
          starttime: opts.starttime
          endtime: opts.endtime
          resolution: opts.resolution

      promise.then (resp) ->
        for def in tempLogsQues by 1
          def.resolve resp.data
      promise.catch (err) ->
        for def in tempLogsQues by 1
          if err.toString().indexOf('SyntaxError') > -1
            def.reject
              status: 500
              statusText: err
          else
            def.reject(err)
      promise.finally ->
        fetchingTempLogs = false
        tempLogsQues = []

      return deferred.promise

    self.getAmplificationData = (expId) ->
      deferred = $q.defer()
      $http.get("/experiments/#{expId}/amplification_data").then (resp) ->
        deferred.resolve(resp)
      , (resp) ->
        if resp.toString().indexOf('SyntaxError') > -1
          deferred.reject
            status: 500
            statusText: resp
        else
          deferred.reject(resp)

      return deferred.promise

    self.getMeltCurveData = (expId) ->
      deferred = $q.defer()
      $http.get("/experiments/#{expId}/melt_curve_data").then (resp) ->
        deferred.resolve(resp)
      , (resp) ->
        if resp.toString().indexOf('SyntaxError') > -1
          deferred.reject
            status: 500
            statusText: resp
        else
          deferred.reject(resp)

      return deferred.promise

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

    self.hasAmplificationCurve = (exp) ->
      stages = exp.protocol.stages
      return stages.some((val) => val.stage.name is "Cycling Stage")

    self.hasMeltCurve = (exp) ->
      stages = exp.protocol.stages
      return stages.some((val) => val.stage.name is "Melt Curve Stage")

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
