window.ChaiBioTech.ngApp.controller('userDataController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  '$uibModal',
  'userFormErrors',
  function($scope, $stateParams, userService, $state, $uibModal, userFormErrors) {

    $scope.id = $stateParams.id || 'current';
    $scope.userData = {};
    $scope.resetPassStatus = false;
    $scope.userData.password = "";
    $scope.userData.password_confirmation = "";
    $scope.isAdmin = $scope.allowEditPassword = $scope.allowButtons = $scope.passError = false;
    $scope.cancelButton = true;
    $scope.deleteButton = true;
    $scope.emailAlreadtTaken = false;

    $scope.getUserData = function() {
      if(isNaN($scope.id)) {
        //userService.curr
      }
      userService.findUSer($scope.id).
        then(function(data) {
          $scope.id = data.user.id;
          $scope.userData = data.user;
        });
    };

    $scope.currentLogin = function() {
      userService.findUSer("current").
        then(function(data) {
          if(data.user.role === "admin") {
            $scope.isAdmin = $scope.allowEditPassword = $scope.allowButtons = true;
          }
          if($state.is("settings.current-user")) {
            console.log("okay Inside");
            $scope.isAdmin = false;
            $scope.allowEditPassword = $scope.allowButtons = true;
            $scope.deleteButton = false;
          }
        });

    };

    $scope.resetPass = function() {

      $scope.userData.password = "";
      $scope.userData.password_confirmation = "";
      $scope.resetPassStatus = true;
    };

    $scope.deleteUser = function() {

      userService.remove($scope.id).then(function(data) {
        $state.go('settings.usermanagement', {}, { reload: true });
      });
    };

    $scope.update = function(form) {

      $scope.passError = ($scope.userData.password !== $scope.userData.password_confirmation);
      if(form.$valid && ! $scope.passError) {

        var format = {'user': $scope.userData};
        userService.updateUser($scope.id, format)
        .then(function(data) {
          $scope.resetPassStatus = false;
          if($state.is("settings.current-user")) {
            $state.transitionTo('settings.root', {}, { reload: true });
          } else {
            $state.transitionTo('settings.usermanagement', {}, { reload: true });
          }

        }, function(err) {
            userFormErrors.handleError($scope, err);
        });
      }

    };

    $scope.deleteMessage = function() {
      $scope.uiModal = $uibModal.open({
        templateUrl: 'app/views/settings/delete-user.html',
        scope: $scope,
      });
    };

    $scope.getUserData();
    $scope.currentLogin();
  }
]);
