
window.ChaiBioTech.ngApp.controller('CreateTestKitModalCtrl', [
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

        $scope.modal_title = "Choose Kit Manufacturer";
        $scope.brands = [
            {
                name: "chai",
                guid: 'chai_coronavirus_env_kit',
                logo: '/images/Chai Badge.svg',
            },
            // {
            //     name: "neogen",
            //     guid: '',
            //     logo: '/images/neogen.png',
            // },
            // {
            //     name: "nephros",
            //     guid: '',
            //     logo: '/images/nephros.png',
            // },
            {
                name: "pika",
                guid: 'pika_4e_kit',
                logo: '/images/PIKA Logo Vector.svg',
            },
        ];

        $scope.test_kit_set = {
            chai: {
                title: 'Chai Test Kits',
                categories: [],
                kits: [
                    {
                        kit_id: 'coronavirus-env-surface',
                        name: 'Coronavirus Environmental Surface',
                        target_name: 'SARS-CoV-2'
                    },
                    {
                        kit_id: 'covid-19-surveillance',
                        name: 'COVID-19 Surveillance',
                        target_name: 'SARS-CoV-2'
                    },
                ],
            },
            pika: {
                title: 'PIKA Weihenstephan Test Kits',
                categories: ["Bacteria 4e Kits", "Yeast 4e Kits"],
                kits: [
                    //Bacteria 4e Kits
                    {
                        name: 'Acetics screening',
                        kit_id: '(2401-15)',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Alicyclobacillus screening',
                        kit_id: '(2401-18)',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Lactobacillaceae screening',
                        kit_id: '(2401-32)',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'L. acetotolerans detection',
                        kit_id: '(2401-52)',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'LP Real Beer Spoiler screening',
                        kit_id: '(2401-38)',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Megasphaera screening',
                        kit_id: '(2401-41)',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Pectinatus screening',
                        kit_id: '(2401-44)',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Single spoiler detection',
                        kit_id: '(2401-NN)',
                        category: 'Bacteria 4e Kits'
                    },

                    //Yeast 4e Kits
                    {
                        name: 'Brettanomyces (Dekkera) screening',
                        kit_id: '(2402-20)',
                        category: 'Yeast 4e Kits'
                    },
                    {
                        name: 'S. diastaticus detection',
                        kit_id: '(2402-49)',
                        category: 'Yeast 4e Kits'
                    },
                    {
                        name: 'Superattenuator yeasts screening',
                        kit_id: '(2402-58)',
                        category: 'Yeast 4e Kits'
                    },
                ],
            },
        };

        $scope.selected_brand = null;
        $scope.current_step = 'brand';
        $scope.action_button_name = 'Next';
        $scope.back_button_name = 'Cancel';
        $scope.selected_kit_1 = null;
        $scope.selected_kit_2 = null;
        $scope.current_kit_type = 'one';
        $scope.test_kits = [];

        $scope.selectBrand = function(item) {
            switch(item.name){
            case 'neogen':
            case 'nephros':
                $scope.selected_brand = null;
                break;
            default:
                $scope.selected_brand = item;
                break;
            }
        };

        $scope.onBackStep = function() {
            if($scope.current_step == 'brand'){
                $scope.$dismiss();
            } else {
                $scope.current_step = 'brand';
                $scope.selected_kit_1 = null;
                $scope.selected_kit_2 = null;
            }
            $scope.back_button_name = 'Cancel';
            $scope.action_button_name = 'Next';
            $scope.modal_title = "Choose Kit Manufacturer";
        };

        $scope.onSelectKitType = function(type) {
            $scope.current_kit_type = type;
        };

        $scope.onSelectKit1 = function(item) {
            $scope.selected_kit_1 = item;
        };

        $scope.onSelectKit2 = function(item) {
            $scope.selected_kit_2 = item;
        };

        $scope.onNextStep = function() {
            switch($scope.current_step) {
            case 'brand':
                if($scope.selected_brand){
                    if($scope.selected_brand.name == 'chai'){
                        $scope.current_step = 'signle_kit';
                    } else {
                        $scope.current_step = 'multi_kit';
                    }
                    $scope.test_kits = $scope.test_kit_set[$scope.selected_brand.name].kits;
                    $scope.modal_title = $scope.test_kit_set[$scope.selected_brand.name].title;
                    $scope.action_button_name = 'Run Kit';
                    $scope.back_button_name = 'Back';
                }
                break;
            default:
                if($scope.current_step=='signle_kit' && $scope.selected_kit_1) {
                    $scope.signleCreate();
                } else if(($scope.current_step=='multi_kit' && $scope.current_kit_type=='one' && $scope.selected_kit_1) ||
                    ($scope.current_step=='multi_kit' && $scope.current_kit_type=='two' && $scope.selected_kit_2 && $scope.selected_kit_1)){
                    $scope.multiCreate();
                }
                break;
            }
        };

        $scope.creating = false;
        $scope.signleCreate = function(){
            $scope.creating = true;
            $scope.kit1 = $scope.selected_kit_1;
            var target2_name = '';
            var sample2_name = '';
            if ($scope.selected_brand.name == 'chai'){
                switch($scope.kit1.kit_id){
                    case 'coronavirus-env-surface':
                        target2_name = 'IAC';
                        break;
                    case 'covid-19-surveillance':
                        target2_name = 'RPLP0';
                        break;
                }
                sample2_name = 'No Template Control';
            } else {
                target2_name = 'IPC';
                sample2_name = 'Negative Control';
            }

            $scope.wells = [
                {'well_num':1,'well_type':'positive_control','sample_name':'Positive Control','notes':'','targets':['','']},
                {'well_num':2,'well_type':'no_template_control','sample_name':sample2_name,'notes':'','targets':['','']},
                {'well_num':3,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':4,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':5,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':6,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':7,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':8,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':9,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':10,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':11,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':12,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':13,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':14,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':15,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                {'well_num':16,'well_type':'sample','sample_name':'','notes':'','targets':['','']}
            ];

            Testkit.create({guid:$scope.selected_brand.guid ,name:$scope.kit1.name}).then(function (resp){
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
                    Experiment.createSample(new_experiment_id,{name: sample2_name}).then(function(resp) {
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
                    Experiment.createTarget(new_experiment_id,{name: $scope.kit1.target_name, channel: 1}).then(function(resp) {
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
                    Experiment.createTarget(new_experiment_id,{name: target2_name, channel: 2}).then(function(resp) {
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
        };

        $scope.multiCreate = function(){
            $scope.creating = true;
            $scope.selectedKit = ($scope.current_kit_type=='one') ? 1 : 2;
            $scope.kit1 = $scope.selected_kit_1;
            $scope.kit2 = $scope.selected_kit_2;
            var target1_kit1_name = ($scope.kit1.target_name) ? $scope.kit1.target_name : $scope.kit1.name;
            var target2_name = 'IPC';

            if($scope.selectedKit == 1 || ($scope.selectedKit == 2 && $scope.kit1.name == $scope.kit2.name )){
                $scope.wells = [
                    {'well_num':1,'well_type':'positive_control','sample_name':'Positive Control','notes':'','targets':['','']},
                    {'well_num':2,'well_type':'no_template_control','sample_name':'Negative Control','notes':'','targets':['','']},
                    {'well_num':3,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':4,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':5,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':6,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':7,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':8,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':9,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':10,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':11,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':12,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':13,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':14,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':15,'well_type':'sample','sample_name':'','notes':'','targets':['','']},
                    {'well_num':16,'well_type':'sample','sample_name':'','notes':'','targets':['','']}
                ];

                Testkit.create({guid:$scope.selected_brand.guid, name:$scope.kit1.name}).then(function (resp){
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
                        Experiment.createTarget(new_experiment_id,{name: target1_kit1_name, channel: 1}).then(function(resp) {
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
                        Experiment.createTarget(new_experiment_id,{name: target2_name, channel: 2}).then(function(resp) {
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
                var target1_kit2_name = ($scope.kit2.target_name) ? $scope.kit2.target_name : $scope.kit2.name;
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
                Testkit.create({guid:$scope.selected_brand.guid,name:$scope.kit1.name + ' & ' + $scope.kit2.name }).then(function (resp){
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
                        Experiment.createTarget(new_experiment_id,{name: target1_kit1_name, channel: 1}).then(function(resp) {
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
                        Experiment.createTarget(new_experiment_id,{name: target1_kit2_name, channel: 1}).then(function(resp) {
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
                        Experiment.createTarget(new_experiment_id,{name: target2_name, channel: 2}).then(function(resp) {
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
