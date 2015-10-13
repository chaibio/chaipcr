window.ChaiBioTech.ngApp.service 'TestInProgressHelper', [
  'AmplificationChartHelper'
  '$rootScope'
  'Experiment'
  '$q'
  'Status'
  (AmplificationChartHelper, $rootScope, Experiment, $q, Status) ->

    directivesCount = 0
    status = null
    experiment = null
    holding = false
    isFetchingExp = false
    experimentQues = []

    $rootScope.$watch =>
      Status.getData()
    , (data) =>
      status = data
      @setHolding status, experiment

    @getExperiment = (id) ->
      deferred = $q.defer()
      experimentQues.push deferred

      if !isFetchingExp
        isFetchingExp = true
        fetchPromise = Experiment.get(id: id).$promise
        fetchPromise.then (resp) =>
          @setHolding status, experiment
          for def in experimentQues by 1
            experiment = resp.experiment
            def.resolve experiment

        fetchPromise.catch (err) ->
          for def in experimentQues by 1
            def.reject err
        fetchPromise.finally ->
          isFetchingExp = false
          experimentQues = []

      deferred.promise

    @isHolding = -> holding

    @setHolding = (data, experiment) ->
      return false if !experiment
      return false if !experiment.protocol
      return false if !experiment.protocol.stages
      return false if !data.experimentController
      return false if !data.experimentController.expriment
      stages = experiment.protocol.stages
      steps = stages[stages.length-1].stage.steps
      max_cycle = parseInt(AmplificationChartHelper.getMaxExperimentCycle(experiment))
      duration = parseInt(steps[steps.length-1].step.delta_duration_s)
      current_stage = parseInt(data.experimentController.expriment.stage.number)
      current_step = parseInt(data.experimentController.expriment.step.number)
      current_cycle = parseInt(data.experimentController.expriment.stage.cycle)

      holding = duration is 0 and stages.length is current_stage and steps.length is current_step and current_cycle is max_cycle

    return
]