window.ChaiBioTech.ngApp

.service 'Status', [
  '$resource'
  ($resource) ->

    self = $resource('/status/:id', {id: '@id'}, {
      fetch:
        method: 'GET'
        isArray: false
    })

]