$(document).ready ->
  angular.bootstrap document, ['ChaiBioTech']
  # $.get('/loggedin')
  # .done (resp) ->
  #   window.authToken = resp.authentication_token
  #   angular.bootstrap document, ['ChaiBioTech']

  # .fail (resp) ->
  #   err = resp.responseJSON.errors

  #   if err is 'login in'
  #     window.history.pushState({}, 'login', '#/login');

  #   if err is 'sign up'
  #     window.history.pushState({}, 'signup', '#/signup');

  #   angular.bootstrap document, ['ChaiBioTech']
