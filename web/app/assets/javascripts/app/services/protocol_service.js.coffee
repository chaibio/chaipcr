window.ChaiBioTech.ngApp

.service 'ExperimentLoader', [
  'Experiment'
  '$q'
  '$stateParams'
  (Experiment, $q, $stateParams) ->

    @getExperiment = ->
      delay = $q.defer()

      Experiment.get({'id': $stateParams.id}, (data) ->
        delay.resolve(data)
      )

      return delay.promise


    @devide = ->


    return

]
