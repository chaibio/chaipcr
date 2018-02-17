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

window.ChaiBioTech.ngApp.controller('newUserController', [
  '$scope',
  '$stateParams',
  'User',
  '$state',
  '$uibModal',
  'userFormErrors',
  function($scope, $stateParams, userService, $state, $uibModal, userFormErrors) {

    $scope.id = $stateParams.id;
    $scope.userData = {
      'name': "",
      'email': "",
      'password': "",
      'password_confirmation': ""
    };

    $scope.resetPassStatus = true;
    $scope.isAdmin = false;
    $scope.allowEditPassword = $scope.allowButtons = true;
    $scope.passError = false;
    $scope.passLengthError = false;
    $scope.emailAlreadtTaken = false;
    $scope.editable = true;

    $scope.update = function(form) { // This method actually saves and create a new user
      //console.log("bingo123", $scope.userData);
      if(form.$valid && ! $scope.passError) {
        var format = $scope.userData;
        userService.save(format).then(function(data) {
          $scope.resetPassStatus = false;
          $state.transitionTo('settings.usermanagement', {}, { reload: true });
        }, function(err) {
          console.log("there is some issue", err, userFormErrors);
          var problem = err.user;
          userFormErrors.handleError($scope, problem, form);
        });
      }
    };

    $scope.emailKeyDown = function(form) {
      form.emailField.$setValidity('emailAlreadtTaken', true);
    };

    $scope.comparePass = function(form) {
      if($scope.userData.password !== $scope.userData.password_confirmation) {
        form.password.$setValidity('confirmPassword', false);
        form.confirmPassword.$setValidity('confirmPassword', false);
      } else if($scope.userData.password === $scope.userData.password_confirmation){
        form.password.$setValidity('confirmPassword', true);
        form.confirmPassword.$setValidity('confirmPassword', true);
      }
    };

    $scope.currentLogin = function() {
      
      userService.findUSer("current").
        then(function(data) {
          if(data.user.role === "admin") {
            $scope.isAdmin = true;
          }
        });
    };

    $scope.currentLogin();
  }
]);
