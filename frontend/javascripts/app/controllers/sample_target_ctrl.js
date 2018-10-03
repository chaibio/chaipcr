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

window.ChaiBioTech.ngApp.controller('SampleTargetCtrl', [
    '$scope',
    'Status',
    '$http',
    'Device',
    '$window',
    '$timeout',
    '$location',
    '$state',
    'Experiment',
    '$uibModal',
    '$stateParams',
    'AmplificationChartHelper',
    'SampleTargetDelete',
    function($scope, Status, $http, Device, $window, $timeout, $location, $state, Experiment, $uibModal, $stateParams, AmplificationChartHelper, SampleTargetDelete) {

        Experiment.get({id: $stateParams.id}).then(function(response){
            $scope.experiment = response.experiment;
        });

        Device.isDualChannel().then(function(is_dual_channel){
            $scope.is_dual_channel = is_dual_channel ;
        });

        $scope.rows = [];
        $scope.targets = [];
        $scope.colors = AmplificationChartHelper.SAMPLE_TARGET_COLORS;
        $scope.isAddSample = true;
        $scope.isAddTarget = true;

        $scope.getSamples = function(){
            Experiment.getSamples($stateParams.id).then(function(resp){
                $scope.rows = [];
                var i;
                for (i = 0; i < resp.data.length; i++) {
                    $scope.rows[i] = resp.data[i].sample;
                    $scope.rows[i].confirmDelete = false;
                    if(resp.data[i].sample.samples_wells.length > 0){
                        $scope.rows[i].assigned = true;
                    }
                    else{
                        $scope.rows[i].assigned = false;
                    }
                }
                if(resp.data.length == 0){
                    $scope.create();
                }
                $scope.isAddSample = true;
            });         
        };

        $scope.getTargets = function(){
            Experiment.getTargets($stateParams.id).then(function(resp){
                $scope.targets = [];
                var i;
                for (i = 0; i < resp.data.length; i++) {
                    $scope.targets[i] = resp.data[i].target;
                    $scope.targets[i].confirmDelete = false;
                    $scope.targets[i].selectChannel = false;
                    if(resp.data[i].target.targets_wells.length > 0){
                        $scope.targets[i].assigned = true;
                    }
                    else{
                        $scope.targets[i].assigned = false;
                    }
                }
                if(resp.data.length == 0){
                    $scope.createTarget();
                }               
                $scope.isAddTarget = true;
            });
        };

        $scope.getSamples();
        $scope.getTargets();

        $scope.validItemName = function(type){
            var index = 0, isExist = true;
            if(type == 'Sample'){
                index = $scope.rows.length;
                while(isExist){
                    isExist = false;
                    for (i = 0; i < $scope.rows.length; i++) {
                        if($scope.rows[i].name == 'Sample ' + index){
                            isExist = true;
                            break;
                        }
                    }
                    if(isExist){
                        index++;
                    }
                }
                return 'Sample ' + index;
            } else {
                index = $scope.targets.length;
                while(isExist){
                    isExist = false;
                    for (i = 0; i < $scope.targets.length; i++) {
                        if($scope.targets[i].name == 'Target ' + index){
                            isExist = true;
                            break;
                        }
                    }
                    if(isExist){
                        index++;
                    }
                }

                return 'Target ' + index;
            }
        };

        $scope.create = function() {
            if($scope.rows.length >= 16) return;
            if(!$scope.isAddSample) return;

            $scope.isAddSample = false;
            var vailidSampleName = $scope.validItemName('Sample');
            Experiment.createSample($stateParams.id,{name: vailidSampleName}).then(function(response) {
                $scope.getSamples();                
            });
        };

        $scope.createTarget = function(){
            if(!$scope.isAddTarget) return;

            $scope.isAddTarget = false;
            var vailidTargetName = $scope.validItemName('Target');

            Experiment.getTargets($stateParams.id).then(function(resp){
                Experiment.createTarget($stateParams.id,{name: vailidTargetName, channel: 1}).then(function(response) {
                    $scope.getTargets();
                });
            });
        };

        $scope.updateTargetChannel = function(id, value){
            Experiment.updateTarget($stateParams.id, id, {channel: value}).then(function(resp) {
                $scope.getTargets();
            });
        };

        $scope.focusSample = function (id, value, indexValue){
            if(value == "Sample " + (indexValue+1)){
                $scope.rows[indexValue].name = "";
            }
        };

        $scope.focusTarget = function (id, value, indexValue){
            if(value == "Target " + (indexValue+1)){
                $scope.targets[indexValue].name = "";
            }
        };

        $scope.updateSample = function(id, value, indexValue) {
            document.activeElement.blur();
            if(value == ""){
                value = "Sample " + (indexValue+1);
            }
            Experiment.updateSample($stateParams.id, id, {name: value}).then(function(resp) {
                $scope.getSamples();
            });
            //$scope.editExpNameMode[index] = false;
            //$scope.samples[index - 3] = x;
        };

        $scope.updateTargetName = function(id, value, indexValue) {
            document.activeElement.blur();
            if(value == ""){
                value = "Target " + (indexValue+1);
            }
            Experiment.updateTarget($stateParams.id, id, {name: value}).then(function(resp) {
                $scope.getTargets();
            });
            //$scope.editExpNameMode[index] = false;
            //$scope.samples[index - 3] = x;
        };

        $scope.confirmDeleteSample = function (rowContent) {
            SampleTargetDelete.disableActiveDelete();
            SampleTargetDelete.activeDelete = rowContent;
            rowContent.confirmDelete = true;
            $scope.deleteItemName = rowContent.name;
            $scope.deleteItemType = 'Sample';
        };

        $scope.confirmDeleteTarget = function (targetContent) {
            SampleTargetDelete.disableActiveDelete();
            SampleTargetDelete.activeDelete = targetContent;
            targetContent.confirmDelete = true;
            $scope.deleteItemName = targetContent.name;
            $scope.deleteItemType = 'Target';
        }; 

        $scope.deleteSampleItem = function(rowContent) {
            Experiment.deleteLinkedSample($stateParams.id, rowContent.id).then(function(resp){
                if($scope.confirmModal) $scope.confirmModal.close();
                $scope.getSamples();
            })
            .catch(function(response){
                if(response.status == 422){
                    console.log(response.data.sample.errors.base[0]);
                }
            });
        };

        $scope.deleteSample = function (rowContent, $event) {
            if(rowContent.assigned){
                $scope.deleteConfirmModal().result.then(function() {
                  $scope.deleteSampleItem(rowContent);
                });
            } else {
                $scope.deleteSampleItem(rowContent);                
            }
        };

        $scope.deleteTargetItem = function (targetContent) {
            Experiment.deleteLinkedTarget($stateParams.id,targetContent.id).then(function(resp){
                $scope.getTargets();
                if($scope.confirmModal) $scope.confirmModal.close();
            })
            .catch(function(response){
                if(response.status == 422){
                    console.log(response.data.target.errors.base[0]);
                }
            });
        };

        $scope.deleteTarget = function (targetContent, $event) {
            if(targetContent.assigned){
                $scope.deleteConfirmModal().result.then(function() {
                  $scope.deleteTargetItem(targetContent);
                });
            } else {
                $scope.deleteTargetItem(targetContent);
            }
        };

        $scope.openImportStandards = function(){
            modalInstance = $uibModal.open({
                templateUrl: 'app/views/import-standards.html',
                controller: 'SampleTargetCtrl',
                openedClass: 'modal-open-standards',
                backdrop: false
            });
            return modalInstance;
        };

        $scope.deleteConfirmModal = function(){
            $scope.confirmModal = $uibModal.open({
                scope: $scope,
                templateUrl: 'app/views/modals/modal-delete-confirm.html',
                controller: 'SampleTargetCtrl',
                openedClass: 'modal-open-confirm-delete',
                backdrop: false
            });

            return $scope.confirmModal;
        };        
    }

]);
