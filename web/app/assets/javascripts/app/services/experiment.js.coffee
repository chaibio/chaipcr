window.ChaiBioTech.ngApp

.service 'Experiment', [
  '$resource'
  ($resource) ->

    $resource('/experiments/:id', {id: '@id'}, {
      update:
        method: 'PUT'
    })

]