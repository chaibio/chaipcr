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

window.ChaiBioTech.ngApp.controller('CreateTestKitCtrl', [
    'Device',
    'Experiment',
    '$scope',
    'Status',
    '$http',
    '$window',
    '$timeout',
    '$location',
    '$state',
    'Testkit',
    function(Device, Experiment, $scope, Status, $http, $window, $timeout, $location, $state, Testkit) {

        $scope.is_dual_channel = false;
        $scope.update_available = 'unavailable';
        $scope.exporting = false;
        $scope.value = "PIKA Weihenstephan";
        $scope.selectedKit = 1;
        $scope.kit = {
            name: 'Acetics screening'
        };
        $scope.kit1 = {
            name: 'Acetics screening'
        };
        $scope.kit2 = {
            name: 'Acetics screening'
        };

        $scope.sample_positive_1 = '';
        $scope.sample_negative_2 = '';
        $scope.sample_positive_9 = '';
        $scope.sample_negative_10 = '';
        $scope.target_1 = '';
        $scope.target_2 = '';
        $scope.target_ipc = '';

        $scope.creating = false;

        $scope.myFunction = function() {
            document.getElementById("myDropdown").classList.toggle("show");
        };

        $scope.select = function(kit){
            // alert(kit);
        };

        $scope.create = function(){
            $scope.creating = true;
            if($scope.selectedKit == 1 || ($scope.selectedKit == 2 && $scope.kit1.name == $scope.kit2.name )){
                $scope.wells = [
                    {'well_num':1,'well_type':'positive_control','sample_name':'Positive Control','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':2,'well_type':'no_template_control','sample_name':'Negative Control','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':3,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':4,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':5,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':6,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':7,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':8,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':9,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':10,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':11,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':12,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':13,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':14,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':15,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']},
                    {'well_num':16,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit.name,'']}
                ];

                Testkit.create({guid:'pika_4e_kit',name:$scope.kit.name}).then(function (resp){
                    var new_experiment_id = resp.data.experiment.id;
                    var tasks = [];

                    // Positive Control
                    tasks.push(function(cb) {
                        Experiment.createSample(new_experiment_id,{name: 'Positive Control'}).then(function(resp) {
                            $scope.sample_positive_1 = resp.data.sample;
                            Experiment.linkSample(new_experiment_id, $scope.sample_positive_1.id, { wells: [1] }).then(function (response) {                                
                                cb(null, response.data.sample.samples_wells);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });

                    });

                    // Negetive Control
                    tasks.push(function(cb) {
                        Experiment.createSample(new_experiment_id,{name: 'Negative Control'}).then(function(resp) {
                            $scope.sample_negative_2 = resp.data.sample;
                            Experiment.linkSample(new_experiment_id, $scope.sample_negative_2.id, { wells: [2] }).then(function (response) {                                
                                cb(null, response.data.sample.samples_wells);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });

                    });

                    // Target 1
                    tasks.push(function(cb) {
                        Experiment.createTarget(new_experiment_id,{name: $scope.kit.name, channel: 1}).then(function(resp) {
                            $scope.target_1 = resp.data.target;
                            var linkTargetName = [];
                            linkTargetName[0] = {
                                well_num: 1,
                                well_type: 'positive_control'
                            };
                            linkTargetName[1] = {
                                well_num: 2,
                                well_type: 'negative_control'
                            };

                            Experiment.linkTarget(new_experiment_id, $scope.target_1.id, { wells: linkTargetName }).then(function (response) {                                
                                cb(null, response);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });
                    });

                    // Target - IPC
                    tasks.push(function(cb) {
                        Experiment.createTarget(new_experiment_id,{name: 'IPC', channel: 2}).then(function(resp) {
                            $scope.target_ipc = resp.data.target;
                            var linkTargetName = [];
                            linkTargetName[0] = {
                                well_num: 1,
                                well_type: 'positive_control'
                            };
                            linkTargetName[1] = {
                                well_num: 2,
                                well_type: 'negative_control'
                            };
                            Experiment.linkTarget(new_experiment_id, $scope.target_ipc.id, { wells: linkTargetName }).then(function (response) {                                
                                cb(null, response);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });
                    });

                    async.parallel(tasks, function(error, results) {
                        if (error) {                            
                            $scope.creating = false;
                            $scope.error = response.data.errors || "An error occured while trying to create the experiment.";
                        } else {
                            $state.go('pika_test.set-wells', {id: new_experiment_id});
                            $scope.$close();
                        }
                    });
                });
            }
            else if($scope.selectedKit == 2 && $scope.kit1.name != $scope.kit2.name){
                $scope.wells = [
                    {'well_num':1,'well_type':'positive_control','sample_name':'Positive Control','notes':'','targets':[$scope.kit1.name,'']},
                    {'well_num':2,'well_type':'no_template_control','sample_name':'Negative Control','notes':'','targets':[$scope.kit1.name,'']},
                    {'well_num':3,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
                    {'well_num':4,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
                    {'well_num':5,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
                    {'well_num':6,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
                    {'well_num':7,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
                    {'well_num':8,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit1.name,'']},
                    {'well_num':9,'well_type':'sample','sample_name':'Positive Control','notes':'','targets':[$scope.kit2.name,'']},
                    {'well_num':10,'well_type':'sample','sample_name':'Negative Control','notes':'','targets':[$scope.kit2.name,'']},
                    {'well_num':11,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
                    {'well_num':12,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
                    {'well_num':13,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
                    {'well_num':14,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
                    {'well_num':15,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']},
                    {'well_num':16,'well_type':'sample','sample_name':'','notes':'','targets':[$scope.kit2.name,'']}
                ];
                Testkit.create({guid:'pika_4e_kit',name:$scope.kit1.name + ' & ' + $scope.kit2.name }).then(function (resp){
                    var new_experiment_id = resp.data.experiment.id;
                    var tasks = [];

                    // Positive Control 1
                    tasks.push(function(cb) {
                        Experiment.createSample(new_experiment_id,{name: 'Positive Control'}).then(function(resp) {
                            $scope.sample_positive_1 = resp.data.sample;
                            Experiment.linkSample(new_experiment_id, $scope.sample_positive_1.id, { wells: [1] }).then(function (response) {                                
                                cb(null, response.data.sample.samples_wells);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {
                            cb(null, null);
                        });

                    });

                    // Negetive Control 2
                    tasks.push(function(cb) {
                        Experiment.createSample(new_experiment_id,{name: 'Negative Control'}).then(function(resp) {
                            $scope.sample_negative_2 = resp.data.sample;
                            Experiment.linkSample(new_experiment_id, $scope.sample_negative_2.id, { wells: [2] }).then(function (response) {                                
                                cb(null, response.data.sample.samples_wells);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });

                    });


                    // Positive Control 9
                    tasks.push(function(cb) {
                        Experiment.createSample(new_experiment_id,{name: 'Positive Control'}).then(function(resp) {
                            $scope.sample_positive_9 = resp.data.sample;
                            Experiment.linkSample(new_experiment_id, $scope.sample_positive_9.id, { wells: [9] }).then(function (response) {                                
                                cb(null, response.data.sample.samples_wells);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });

                    });

                    // Negetive Control 10
                    tasks.push(function(cb) {
                        Experiment.createSample(new_experiment_id,{name: 'Negative Control'}).then(function(resp) {
                            $scope.sample_negative_10 = resp.data.sample;
                            Experiment.linkSample(new_experiment_id, $scope.sample_negative_10.id, { wells: [10] }).then(function (response) {                                
                                cb(null, response.data.sample.samples_wells);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });

                    });


                    // Target 1
                    tasks.push(function(cb) {
                        Experiment.createTarget(new_experiment_id,{name: $scope.kit1.name, channel: 1}).then(function(resp) {
                            $scope.target_1 = resp.data.target;
                            var linkTargetName = [];
                            linkTargetName[0] = {
                                well_num: 1,
                                well_type: 'positive_control'
                            };
                            linkTargetName[1] = {
                                well_num: 2,
                                well_type: 'negative_control'
                            };

                            Experiment.linkTarget(new_experiment_id, $scope.target_1.id, { wells: linkTargetName }).then(function (response) {                                
                                cb(null, response);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });
                    });

                    // Target 2
                    tasks.push(function(cb) {
                        Experiment.createTarget(new_experiment_id,{name: $scope.kit2.name, channel: 1}).then(function(resp) {
                            $scope.target_2 = resp.data.target;
                            var linkTargetName = [];
                            linkTargetName[0] = {
                                well_num: 9,
                                well_type: 'positive_control'
                            };
                            linkTargetName[1] = {
                                well_num: 10,
                                well_type: 'negative_control'
                            };

                            Experiment.linkTarget(new_experiment_id, $scope.target_2.id, { wells: linkTargetName }).then(function (response) {                                
                                cb(null, response);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });
                    });


                    // Target - IPC
                    tasks.push(function(cb) {
                        Experiment.createTarget(new_experiment_id,{name: 'IPC', channel: 2}).then(function(resp) {
                            $scope.target_ipc = resp.data.target;
                            var linkTargetName = [];
                            linkTargetName[0] = {
                                well_num: 1,
                                well_type: 'positive_control'
                            };
                            linkTargetName[1] = {
                                well_num: 2,
                                well_type: 'negative_control'
                            };
                            linkTargetName[2] = {
                                well_num: 9,
                                well_type: 'positive_control'
                            };
                            linkTargetName[3] = {
                                well_num: 10,
                                well_type: 'negative_control'
                            };
                            Experiment.linkTarget(new_experiment_id, $scope.target_ipc.id, { wells: linkTargetName }).then(function (response) {                                
                                cb(null, response);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {                            
                            cb(null, null);
                        });
                    });

                    async.parallel(tasks, function(error, results) {
                        if (error) {                            
                            $scope.creating = false;
                            $scope.error = response.data.errors || "An error occured while trying to create the experiment.";
                        } else {
                            $state.go('pika_test.set-wells', {id: new_experiment_id});
                            $scope.$close();
                        }
                    });
                });
            }
        };
    }

]);
