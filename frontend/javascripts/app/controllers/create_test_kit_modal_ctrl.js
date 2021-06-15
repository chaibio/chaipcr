
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
                        guid: 'chai_coronavirus_env_kit',
                        target_name: 'SARS-CoV-2'
                    },
                    {
                        kit_id: 'covid-19-surveillance',
                        name: 'COVID-19 Surveillance',
                        guid: 'chai_covid19_surv_kit',
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
                        kit_id: '2401-15',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Alicyclobacillus screening',
                        kit_id: '2401-18',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Lactobacillaceae screening',
                        kit_id: '2401-32',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'L. acetotolerans detection',
                        kit_id: '2401-52',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'LP Real Beer Spoiler Identification',
                        kit_id: '2401-37',
                        category: 'Bacteria 4e Kits',
                        guid: 'pika_4e_lp_identification_kit'
                    },
                    {
                        name: 'LP Real Beer Spoiler screening',
                        kit_id: '2401-38',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Megasphaera screening',
                        kit_id: '2401-41',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Pectinatus screening',
                        kit_id: '2401-44',
                        category: 'Bacteria 4e Kits'
                    },
                    {
                        name: 'Single spoiler detection',
                        kit_id: '2401-NN',
                        category: 'Bacteria 4e Kits'
                    },

                    //Yeast 4e Kits
                    {
                        name: 'Brettanomyces (Dekkera) screening',
                        kit_id: '2402-20',
                        category: 'Yeast 4e Kits'
                    },
                    {
                        name: 'S. diastaticus detection',
                        kit_id: '2402-49',
                        category: 'Yeast 4e Kits'
                    },
                    {
                        name: 'Superattenuator yeasts screening',
                        kit_id: '2402-58',
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
        $scope.exclude_two_kits = ['pika_4e_lp_identification_kit'];
        $scope.exclude_two_kits_data = {
            'pika_4e_lp_identification_kit': {
                'create': function(){ $scope.spoilerIdentificationCreate(); },
                'next_route': 'pika_test.set-sample'
            }
        };

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
            if($scope.exclude_two_kits.indexOf(item.guid) >= 0){
                $scope.selected_kit_2 = null;
            }
        };

        $scope.onSelectKit2 = function(item) {
            $scope.selected_kit_2 = item;
            if($scope.selected_kit_1 && $scope.exclude_two_kits.indexOf($scope.selected_kit_1.guid) >= 0){
                $scope.selected_kit_1 = null;
            }
        };

        $scope.onNextStep = function() {
            if(!$scope.isActiveNextButton()) return;
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
                } else {
                    if($scope.exclude_two_kits.indexOf($scope.selected_kit_1.guid) >= 0){
                        if($scope.exclude_two_kits_data[$scope.selected_kit_1.guid].create){
                            $scope.exclude_two_kits_data[$scope.selected_kit_1.guid].create();
                        }
                    } else {
                        $scope.multiCreate();
                    }
                }
                break;
            }
        };

        $scope.isActiveNextButton = function() {
            return ($scope.current_step=='brand' && $scope.selected_brand) || 
                ($scope.current_step=='signle_kit' && $scope.selected_kit_1) || 
                ($scope.current_step=='multi_kit' && $scope.current_kit_type=='one' && $scope.selected_kit_1) ||
                ($scope.current_step=='multi_kit' && $scope.current_kit_type=='two' && $scope.selected_kit_2 && $scope.selected_kit_1) ||
                ($scope.current_step=='multi_kit' && $scope.current_kit_type=='two' && $scope.selected_kit_1 && $scope.exclude_two_kits.indexOf($scope.selected_kit_1.guid) >= 0);            
        };

        $scope.creating = false;
        $scope.signleCreate = function(){
            $scope.creating = true;
            $scope.kit1 = $scope.selected_kit_1;
            var target2_name = '';
            var sample2_name = '';
            if ($scope.selected_brand.name == 'chai'){
                $scope.selected_brand.guid = $scope.kit1.guid;
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
                        switch($scope.selected_brand.guid){
                            case 'chai_coronavirus_env_kit':
                                $state.go('coronavirus-env.set-wells', {id: new_experiment_id});
                                break;
                            case 'chai_covid19_surv_kit':
                                $state.go('covid19-surv.set-wells', {id: new_experiment_id});
                                break;
                            case 'pika_4e_kit':
                                $state.go('pika_test.set-wells', {id: new_experiment_id});
                                break;
                        }
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
                            switch($scope.selected_brand.guid){
                                case 'chai_coronavirus_env_kit':
                                    $state.go('coronavirus-env.set-wells', {id: new_experiment_id});
                                    break;
                                case 'chai_covid19_surv_kit':
                                    $state.go('covid19-surv.set-wells', {id: new_experiment_id});
                                    break;
                                case 'pika_4e_kit':
                                    $state.go('pika_test.set-wells', {id: new_experiment_id});
                                    break;
                            }
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
                        Experiment.createTarget(new_experiment_id,{name: target1_kit1_name, channel: 1}).then(function(target1Resp) {
                            $scope.target_1 = target1Resp.data.target;
                            var linkTargetName = [];
                            linkTargetName[0] = {
                                well_num: 1,
                                well_type: 'positive_control'
                            };
                            linkTargetName[1] = {
                                well_num: 2,
                                well_type: 'negative_control'
                            };

                            Experiment.linkTarget(new_experiment_id, $scope.target_1.id, { wells: linkTargetName }).then(function (target1LinkResp) {

                                // Target 2
                                Experiment.createTarget(new_experiment_id,{name: target1_kit2_name, channel: 1}).then(function(target2Resp) {
                                    $scope.target_2 = target2Resp.data.target;
                                    var linkTargetName = [];
                                    linkTargetName[0] = {
                                        well_num: 9,
                                        well_type: 'positive_control'
                                    };
                                    linkTargetName[1] = {
                                        well_num: 10,
                                        well_type: 'negative_control'
                                    };

                                    Experiment.linkTarget(new_experiment_id, $scope.target_2.id, { wells: linkTargetName }).then(function (target2LinkResp) {

                                        // Target - IPC
                                        Experiment.createTarget(new_experiment_id,{name: target2_name, channel: 2}).then(function(targetIPCResp) {
                                            $scope.target_ipc = targetIPCResp.data.target;
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

                                    }).catch(function(err) {
                                        cb(null, null);
                                    });
                                }).catch(function(err) {
                                    cb(null, null);
                                });

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
                            switch($scope.selected_brand.guid){
                                case 'chai_coronavirus_env_kit':
                                    $state.go('coronavirus-env.set-wells', {id: new_experiment_id});
                                    break;
                                case 'chai_covid19_surv_kit':
                                    $state.go('covid19-surv.set-wells', {id: new_experiment_id});
                                    break;
                                case 'pika_4e_kit':
                                    $state.go('pika_test.set-wells', {id: new_experiment_id});
                                    break;
                            }
                            $scope.$close();
                        }
                    });
                });
            }
        };

        $scope.spoilerIdentificationCreate = function(){
            $scope.creating = true;
            $scope.selectedKit = 1;
            $scope.kit1 = $scope.selected_kit_1;
            var target2_name = 'IPC';

            $scope.wells = [
                {'well_num':1,'well_type':'positive_control','sample_name':'Positive Control','notes':'','targets':['Positive Control','']},
                {'well_num':2,'well_type':'negative_control','sample_name':'Negative Control','notes':'','targets':['Negative Control','']},
                {'well_num':3,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. acetotolerans','']},
                {'well_num':4,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. backii','']},
                {'well_num':5,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. brevis','']},
                {'well_num':6,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. casei','']},
                {'well_num':7,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. collinoides','']},
                {'well_num':8,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. coryniformis','']},
                {'well_num':9,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. lindneri','']},
                {'well_num':10,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. parabuchneri ("frigidus")','']},
                {'well_num':11,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. perolens','']},
                {'well_num':12,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. plantarum','']},
                {'well_num':13,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['L. rossiae','']},
                {'well_num':14,'well_type':'unknown','sample_name':'[SAMPLE NAME]','notes':'','targets':['P. damnosus and P. inopinatus','']},
                {'well_num':15,'well_type':'unknown','sample_name':'','notes':'','targets':['','']},
                {'well_num':16,'well_type':'unknown','sample_name':'','notes':'','targets':['','']}
            ];

            Testkit.create({guid:$scope.selected_kit_1.guid, name:$scope.kit1.name }).then(function (resp){
                var new_experiment_id = resp.data.experiment.id;
                var tasks = [];
                var linkTargetName = [];

                async.map($scope.wells, function (well, done) {
                    if(well.targets[0]){
                        Experiment.createTarget(new_experiment_id,{name: well.targets[0], channel: 1}).then(function(resp) {
                            var target_1 = resp.data.target;
                            Experiment.linkTarget(
                                new_experiment_id, 
                                target_1.id, 
                                { wells: [{ well_num: well.well_num, well_type: well.well_type }] }
                            ).then(function (response) {
                                done(null, response);
                            }).catch(function(err) {
                                done(null, null);
                            });
                        }).catch(function(err) {
                            done(null, null);
                        });
                    } else {
                        done(null, null);
                    }
                }, function (err, result) {

                    // Positive, Negative, Samples
                    tasks.push(function(cb) {
                        Experiment.createSample(new_experiment_id,{name: $scope.wells[0].sample_name}).then(function(resp) {
                            var sample_item = resp.data.sample;
                            Experiment.linkSample(new_experiment_id, sample_item.id, { wells: [$scope.wells[0].well_num] }).then(function (response) {
                                cb(null, response.data.sample.samples_wells);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {
                            cb(null, null);
                        });
                    });

                    tasks.push(function(cb) {
                        Experiment.createSample(new_experiment_id,{name: $scope.wells[1].sample_name}).then(function(resp) {
                            var sample_item = resp.data.sample;
                            Experiment.linkSample(new_experiment_id, sample_item.id, { wells: [$scope.wells[1].well_num] }).then(function (response) {
                                cb(null, response.data.sample.samples_wells);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {
                            cb(null, null);
                        });
                    });

                    tasks.push(function(cb) {
                        Experiment.createSample(new_experiment_id,{name: $scope.wells[2].sample_name}).then(function(resp) {
                            var sample_item = resp.data.sample;
                            Experiment.linkSample(new_experiment_id, sample_item.id, { wells: [3,4,5,6,7,8,9,10,11,12,13,14] }).then(function (response) {
                                cb(null, response.data.sample.samples_wells);
                            }).catch(function(err) {
                                cb(null, null);
                            });
                        }).catch(function(err) {
                            cb(null, null);
                        });
                    });

                    for(var i = 0; i < $scope.wells.length; i++){
                        if($scope.wells[i].sample_name){
                            linkTargetName.push({
                                well_num: $scope.wells[i].well_num,
                                well_type: $scope.wells[i].well_type
                            });
                        }
                    }

                    // Target - IPC
                    tasks.push(function(cb) {
                        Experiment.createTarget(new_experiment_id,{name: target2_name, channel: 2}).then(function(resp) {
                            $scope.target_ipc = resp.data.target;
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
                            switch($scope.selected_brand.guid){
                                case 'chai_coronavirus_env_kit':
                                    $state.go('coronavirus-env.set-wells', {id: new_experiment_id});
                                    break;
                                case 'chai_covid19_surv_kit':
                                    $state.go('covid19-surv.set-wells', {id: new_experiment_id});
                                    break;
                                case 'pika_4e_kit':
                                    if($scope.exclude_two_kits.indexOf($scope.selected_kit_1.guid) >= 0){
                                        $state.go($scope.exclude_two_kits_data[$scope.selected_kit_1.guid].next_route, {id: new_experiment_id});
                                    } else {
                                        $state.go('pika_test.set-wells', {id: new_experiment_id});
                                    }
                                    break;
                            }
                            $scope.$close();
                        }
                    });                    
                });
            });

            return;
        };

    }

]);
