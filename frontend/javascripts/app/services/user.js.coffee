window.ChaiBioTech.ngApp.service 'User', [
  '$http'
  '$q'
  ($http, $q) ->

    user =
      id: $.jStorage.get 'userId', null

    @currentUser = -> user

    @save = (user) ->
      console.log user
      deferred = $q.defer()
      $http.post '/users',
        user: user
      .then (resp) ->
        deferred.resolve resp.data.user

      .catch (resp) ->
        deferred.reject resp.data

      deferred.promise

    @getCurrent = ->
      $http.get('/users/current')

    @fetch = ->
      deferred = $q.defer()
      $http.get('/users').then (resp) ->
        deferred.resolve resp.data

      deferred.promise

    @updateUser = (id, data)->
      console.log data
      deferred = $q.defer()
      $http.put("/users/#{id}", data).then (resp) ->
        deferred.resolve resp.data

      deferred.promise;


    @findUSer = (key)->
      deferred = $q.defer()
      #console.log "getUSerPArt", key
      $http.get('/users/' + key).then (resp) ->
      #$http.get('/users/').then (resp) ->
        deferred.resolve resp.data

      deferred.promise

    @remove = (id) ->
      deferred = $q.defer()
      $http.delete("/users/#{id}").then (resp) ->
        deferred.resolve resp.data

      deferred.promise;


    return

]
