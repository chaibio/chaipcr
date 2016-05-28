/*
 * Chai PCR - Software platform for Open qPCR and Chai's Real-Time PCR instruments.
 * For more information visit http://www.chaibio.com
 *
 * Copyright 2016 Chai Biotechnologies Inc. <info@chaibio.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
    $scope.editable = false;
    $scope.allowToggleAdmin = false;

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
            $scope.editable = true;
            $scope.allowToggleAdmin = true;
          }

          if($state.is("settings.current-user")) {
            $scope.isAdmin = true;
            $scope.allowEditPassword = $scope.allowButtons = true;
            $scope.deleteButton = false;
            $scope.editable = true;
            $scope.allowToggleAdmin = false;
          }

          if($state.is('settings.usermanagement.user') && data.user.id === $scope.id) {
              $scope.isAdmin = true;
              $scope.allowEditPassword = $scope.allowButtons = true;
              $scope.deleteButton = false;
              $scope.editable = true;
              $scope.allowToggleAdmin = false;
          }

          //$scope.editable = $scope.isAdmin || $state.is("settings.current-user");
          //console.log($scope.editable, $scope.isAdmin, $state.is("settings.current-user"));
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
      //console.log(form);
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
          console.log("bingo", form);
            userFormErrors.handleError($scope, err, form);

        });
      }
    };

    $scope.comparePass = function(form) {
      console.log(form);
      if($scope.userData.password !== $scope.userData.password_confirmation) {
        form.password.$setValidity('confirmPassword', false);
        form.confirmPassword.$setValidity('confirmPassword', false);
      } else if($scope.userData.password === $scope.userData.password_confirmation){
        form.password.$setValidity('confirmPassword', true);
        form.confirmPassword.$setValidity('confirmPassword', true);
      }
    };

    $scope.emailKeyDown = function(form) {
      form.emailField.$setValidity('emailAlreadtTaken', true);
    };

    $scope.deleteMessage = function() {

      //e.preventDefault(); // To prevent form being submitted.
      $scope.uiModal = $uibModal.open({
        templateUrl: 'app/views/settings/delete-user.html',
        scope: $scope,
      });
    };

    $scope.getUserData();
    $scope.currentLogin();

  }
]);
