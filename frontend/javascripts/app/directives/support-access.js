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

window.ChaiBioTech.ngApp.directive('supportAccess', [
  'supportAccessService',
  '$uibModal',

  function(supportAccessService, $uibModal) {
    return {
      restric: 'EA',
      replace: true,
      templateUrl: 'app/views/settings/support-access.html',

      link: function(scope, elem, attr) {

        scope.getAccess = function() {

          supportAccessService.accessSupport()
          .then(function(data) { // success
            scope.message = "We have successfully enabled support access. Thank you.";
            scope.getMessage();
          }, function(data) { // Failure
            scope.message = "We could not enable support access at this moment. Please try again later.";
            scope.getMessage();
          });
        };

        scope.getMessage = function() {

          scope.modal = $uibModal.open({
            scope: scope,
            templateUrl: 'app/views/support-access-result.html',
            windowClass: 'small-modal'
            // This is tricky , we used it here so that,
            //Custom size of this modal doesn't change any other modal in use
          });
        };
      }
    };
  }
]);
