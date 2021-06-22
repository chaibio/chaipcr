window.App.controller 'SettingManageUserPanelCtrl', [
  '$scope'
  'User'
  'Device'
  ($scope, User, Device) ->

    $scope.users = []
    $scope.errors = {}
    selected_user = {}
    $scope.login_user = {}
    $scope.open_confirm = false

    init = () ->
      $scope.current_user = null
      $scope.is_add_user = false

      $scope.errors = 
        password: '',
        confirm_password: ''
      $scope.password = 
        new_pwd: '',
        confirm_pwd: ''
      $scope.has_changes = false

    init()
    User.fetch().then (users) ->
      $scope.users = users
      if selected_user.id
        $scope.onSelectUser(selected_user)
        selected_user = {}

    User.getCurrent().then (resp) ->
      $scope.login_user = resp.data.user

    $scope.onSelectUser = (user) ->
      $scope.current_user = angular.copy(user)
      $scope.current_user.is_admin = if $scope.current_user.role == 'admin' then true else false
      $scope.is_reset_password = false
      $scope.has_changes = false
      $scope.is_add_user = false
      $scope.password = 
        new_pwd: '',
        confirm_pwd: ''

    $scope.onResetPassword = () ->
      $scope.is_reset_password = true
      $scope.has_changes = false

    validatorForNewPasswd = () ->
      if $scope.password.new_pwd.length > 0 and $scope.password.new_pwd.length < 4
        return "Too short, minimum 4 characters required"
      if $scope.password.new_pwd.length == 0 and $scope.password.confirm_pwd
        return "Cannot be left blank."
      return ""

    validatorForConfirmPasswd = () ->
      if $scope.password.confirm_pwd.length and $scope.password.confirm_pwd != $scope.password.new_pwd
        return "Password must match."
      return ""

    $scope.$watchCollection 'current_user', (new_val, old_val)->
      if !new_val || !old_val
        return
      $scope.errors.password = validatorForNewPasswd()
      $scope.errors.confirm_password = validatorForConfirmPasswd()
      $scope.has_changes = true and (!$scope.is_reset_password || ($scope.is_reset_password && !$scope.errors.password && !$scope.errors.confirm_password && $scope.password.confirm_pwd && $scope.password.new_pwd))

    $scope.onUserCancel = () ->
      if $scope.is_reset_password
        $scope.is_reset_password = false
        $scope.password = 
          new_pwd: '',
          confirm_pwd: ''
        $scope.errors.password = ''
        $scope.errors.confirm_password = ''
      else
        init()      

    $scope.onAddUser = () ->
      $scope.is_add_user = true
      $scope.is_reset_password = true
      $scope.has_changes = false
      $scope.password = 
        new_pwd: '',
        confirm_pwd: ''
      $scope.errors.password = ''
      $scope.errors.confirm_password = ''
      $scope.current_user = 
        email: '',
        role: '',
        name: '',
        is_admin: false,
        show_banner: true

    $scope.onUserFieldChanged = () ->
      $scope.errors.password = validatorForNewPasswd()
      $scope.errors.confirm_password = validatorForConfirmPasswd()
      $scope.has_changes = true and (!$scope.is_reset_password || ($scope.is_reset_password && !$scope.errors.password && !$scope.errors.confirm_password && $scope.password.confirm_pwd && $scope.password.new_pwd))

    $scope.onSaveChanges = () ->
      if !$scope.has_changes
        return

      if $scope.is_reset_password
        $scope.current_user.password = $scope.password.new_pwd
        $scope.current_user.password_confirmation = $scope.password.confirm_pwd

      $scope.current_user.role = if $scope.current_user.is_admin then 'admin' else 'default'

      if $scope.current_user.id
        User.updateUser($scope.current_user.id, user: $scope.current_user)
        .then (user) ->
          for index in [0...$scope.users.length]
            if $scope.users[index].user.id == user.id
              $scope.users[index].user = user
              break
          $scope.current_user = null
        .catch (data) ->
          $scope.errors.email = data.user.errors.email?[0]
          $scope.errors.name = data.user.errors.name?[0]
          $scope.errors.password = data.user.errors.password?[0]
      else
        User.save($scope.current_user)
        .then (user) ->
          $scope.users.push(user: user)
          $scope.current_user = null
        .catch (data) ->
          $scope.errors.email = data.user.errors.email?[0]
          $scope.errors.name = data.user.errors.name?[0]
          $scope.errors.password = data.user.errors.password?[0]

    $scope.onConfirmDeleteUser = () ->
      $scope.open_confirm = true
      $scope.delete_error = ''

    $scope.onConfirmCancel = () ->
      $scope.open_confirm = false
      $scope.delete_error = ''

    $scope.onDeleteUser = () ->
      $scope.delete_error = ''
      User.remove($scope.current_user.id)
      .then (resp) ->
        for index in [0...$scope.users.length]
          if $scope.users[index].user.id == $scope.current_user.id
            $scope.users.splice(index, 1)
            break
        $scope.current_user = null
        $scope.open_confirm = false
      .catch (error) ->
        $scope.delete_error = error.errors.base?[0]

    $scope.$on 'modal:edit-user', (e, data, oldData) ->
      if $scope.users.length
        $scope.onSelectUser(data.user)
      else
        selected_user = data.user

]
