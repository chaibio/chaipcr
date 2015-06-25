window.ChaiBioTech.ngApp.service 'User', [
  '$http'
  '$q'
  ($http, $q) ->

    @save = (user) ->
      deferred = $q.defer()
      $http.post '/users',
        user: user
      .then (resp) ->
        deferred.resolve resp.data.user

      .catch (resp) ->
        deferred.reject resp.data

      deferred.promise

    @fetch = ->
      deferred = $q.defer()
      $http.get('/users').then (resp) ->
        deferred.resolve resp.data

      deferred.promise

    @remove = (id) ->
      $http.delete("/users/#{id}")

    return

]
