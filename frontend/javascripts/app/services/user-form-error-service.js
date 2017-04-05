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

window.ChaiBioTech.ngApp.service('userFormErrors', [
  function() {
    // Incase more user side errors has to add, Add it here and bring this service.
    // Right now we have only email error , so just resolve in the controller itself
    this.passErr = "bingo";
    this.handleError = function($scope, problem, form) {

      for(var errKey in problem.errors) {
        console.log(errKey);
        if(errKey === 'email' && problem.errors.email[0] == 'is invalid') {
          //$scope.emailAlreadtTaken = true;
          form.emailField.$setValidity('emailInvalid', false);
          //form.emailField.$setValidity('emailAlreadtTaken', false);
        }
        else if (errKey === 'email' && problem.errors.email[0] != 'is invalid'){
          form.emailField.$setValidity('emailAlreadtTaken', false);
        }
        break;
      }
    };
  }
]);
