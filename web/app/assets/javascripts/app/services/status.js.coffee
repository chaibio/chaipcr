window.ChaiBioTech.ngApp

.service 'Status', [
  '$resource'
  ($resource) ->

    self = $resource('http://localhost\\:8000/status/:id', {id: '@id'}, {
      fetch:
        method: 'GET'
        isArray: false
    })

]