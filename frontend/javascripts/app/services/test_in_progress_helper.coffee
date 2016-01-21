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
    experimentQues = {}
    isFetchingExp = false

    $rootScope.$watch =>
      Status.getData()
    , (data) =>
      status = data
      @set_holding status, experiment

    @getExperiment = (id) ->
      deferred = $q.defer()
      experimentQues["exp_id_#{id}"] = experimentQues["exp_id_#{id}"] || []
      experimentQues["exp_id_#{id}"].push deferred

      if !isFetchingExp
        isFetchingExp = true
        fetchPromise = Experiment.get(id: id).$promise
        fetchPromise.then (resp) =>
          @set_holding status, experiment
          experimentQues["exp_id_#{resp.experiment.id}"] = experimentQues["exp_id_#{resp.experiment.id}"] || []
          for def in experimentQues["exp_id_#{resp.experiment.id}"] by 1
            experiment = resp.experiment
            def.resolve experiment

        fetchPromise.catch (err) ->
          for def in experimentQues by 1
            def.reject err
            experiment = null

        fetchPromise.finally ->
          isFetchingExp = false
          experimentQues["exp_id_#{id}"] = []

      deferred.promise

    @is_holding = -> holding

    @set_holding = (data, experiment) ->
      return false if !experiment
      return false if !experiment.protocol
      return false if !experiment.protocol.stages
      return false if !data
      return false if !data.experiment_controller

      stages = experiment.protocol.stages
      steps = stages[stages.length-1].stage.steps
      # max_cycle = parseInt(AmplificationChartHelper.getMaxExperimentCycle(experiment))
      duration = parseInt(steps[steps.length-1].step.delta_duration_s)
      # current_stage = parseInt(data.experiment_controller.expriment.stage.number)
      # current_step = parseInt(data.experiment_controller.expriment.step.number)
      # current_cycle = parseInt(data.experiment_controller.expriment.stage.cycle)
      state = data.experiment_controller.machine.state

      holding = state is 'complete' and duration is 0

      # console.log holding

      holding

    @timeRemaining = (data) ->
      return 0 if !data
      return 0 if !data.experiment_controller
      if data.experiment_controller.machine.state is 'running'
        exp = data.experiment_controller.expriment
        time = (exp.estimated_duration*1+exp.paused_duration*1)-exp.run_duration*1
        if time < 0 then time = 0
        time
      else
        0

    @timePercentage = (data) ->
      return 0 if !data
      return 0 if !data.experiment_controller
      return 0 if data.experiment_controller.machine.state is 'idle'
      timeRemaining = @timeRemaining data
      exp = data.experiment_controller.expriment
      time = exp.run_duration/(exp.estimated_duration*1+exp.paused_duration*1)
      if time < 0 then time = 0
      return time*100

    return
]