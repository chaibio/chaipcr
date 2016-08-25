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

    $rootScope.$on 'status:data:updated', (e, data) =>
      status = data
      @set_holding status, experiment

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
      # current_stage = parseInt(data.experiment_controller.experiment.stage.number)
      # current_step = parseInt(data.experiment_controller.experiment.step.number)
      # current_cycle = parseInt(data.experiment_controller.experiment.stage.cycle)
      state = data.experiment_controller.machine.state

      holding = state is 'complete' and duration is 0

      # console.log holding

      holding

    @timeRemaining = (data) ->
      return 0 if !data
      return 0 if !data.experiment_controller
      if data.experiment_controller.machine.state is 'running'
        exp = data.experiment_controller.experiment
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
      exp = data.experiment_controller.experiment
      time = exp.run_duration/(exp.estimated_duration*1+exp.paused_duration*1)
      if time < 0 then time = 0
      if time > 1 then time = 1
      return time*100

    return
]