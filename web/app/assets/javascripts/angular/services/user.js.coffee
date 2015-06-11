window.ChaiBioTech.ngApp.service 'User', [
  '$http'
  '$q'
  ($http, $q) ->

    @save = (user) ->
      deferred = $q.defer()
      $http.post '/users',
        user: user
      .then (resp) ->
        deferred.resolve resp.data

      deferred.promise

    return

]