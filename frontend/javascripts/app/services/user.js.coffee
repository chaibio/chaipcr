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
window.ChaiBioTech.ngApp.service 'User', [
  '$http'
  '$q'
  ($http, $q) ->

    user =
      id: $.jStorage.get 'userId', null

    @currentUser = -> user

    @save = (user) ->
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
      deferred = $q.defer()
      $http.put("/users/#{id}", data)
        .then (resp) ->
          deferred.resolve resp.data.user

        .catch (resp) ->
          deferred.reject resp.data.user

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
      .catch (resp) ->
        deferred.reject resp.data.user

      deferred.promise;


    return

]
