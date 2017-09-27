describe("Testing ExperimentLoader service", function() {

   var _ExperimentLoader, _Experiment, _$q, _$stateParams, _$rootScope, _$http, $httpBackend;

   beforeEach(function() {
        
        
        module('ChaiBioTech', function($provide) {
            //$provide.value('Experiment',  meth);
        });

        inject(function($injector) {
            $httpBackend = $injector.get('$httpBackend');
            $httpBackend.whenGET("http://localhost:8000/status").respond("NOTHING");
            $httpBackend.whenGET("http://localhost:8000/network/wlan").respond({
                data: {
                    state: {
                        macAddress: "125",
                        status: {

                        }
                    }
                }
            });
            _ExperimentLoader = $injector.get('ExperimentLoader');
            _$q = $injector.get('$q');
            _$stateParams = $injector.get('$stateParams');
            _$rootScope = $injector.get('$rootScope');
            _$http = $injector.get('$http');
            _Experiment = $injector.get('Experiment');
        });

        
            
    });

    /*it("It should test getExperiment method", function() {
        //console.log(_Experiment.get().then(), "Okay");
        //spyOn(_Experiment, "get");
        _Experiment.get = function() {
            var del = _$q.defer();
            del.resolve({experiment: {
                id: 1
            }});
            return del.promise;
        };

        _$stateParams.id = 10;
        _ExperimentLoader.getExperiment();
        //expect(_Experiment.get).toHaveBeenCalled();
   });*/

   it("It should test getExperiment method", function() {
       _$stateParams.id = 10;
        
        $httpBackend.expectGET('/experiments/10').respond({
            experiment: {
                id: 10
            }
        });
        _ExperimentLoader.getExperiment();

        $httpBackend.flush();
        expect(_ExperimentLoader.protocol.id).toEqual(10);

   });

   it("It should test getExperiment method, when server reject the request", function() {
       _$stateParams.id = 10;
        
        $httpBackend.expectGET('/experiments/10').respond(502, '');
        _ExperimentLoader.getExperiment();

        $httpBackend.flush();
        expect(_ExperimentLoader.protocol.id).not.toBeDefined();

   });

   it("It should test loadFirstStages method", function() {
        _ExperimentLoader.protocol = {
            
                protocol: {
                    stages: [
                        {
                            stage: {
                                name: "stage1"
                            }
                        }
                    ]
                }
        };

        var rv = _ExperimentLoader.loadFirstStages();
        expect(rv.name).toEqual("stage1");
   });

   it("It should test loadFirstStep method", function() {

         _ExperimentLoader.protocol = {
            
                protocol: {
                    stages: [
                        {
                            stage: {
                                steps: [
                                    { step: "step1"},
                                    { step: "step2"}
                                ] 
                            }
                        }
                    ]
                }
        };  
        
        var rv = _ExperimentLoader.loadFirstStep();
        expect(rv).toEqual("step1");
   });

   it("It should test getNew mwthod", function() {

        _ExperimentLoader.protocol = {
            
                protocol: {
                    stages: [
                        {
                            stage: {
                                steps: [
                                    { step: "step1"},
                                    { step: "step2"}
                                ] 
                            }
                        },
                        {
                            stage: "target"
                        }
                    ]
                }
        };  
        
        var rv = _ExperimentLoader.getNew();
        expect(rv).toEqual("target");
   });

   it("It should test update method", function() {

        var dataToBeSend = {
            name: "Stage"
        };

        var url = "http://localhost:8000/experiments/10";

        $httpBackend.expectPUT(url).respond({
            status: "okay"
        });

        _ExperimentLoader.update(url, dataToBeSend, _$q.defer());

        $httpBackend.flush();
   });

   it("It should test update method, when server returns error", function() {

        var dataToBeSend = {
            name: "Stage"
        };

        var url = "http://localhost:8000/experiments/10";

        $httpBackend.expectPUT(url).respond(502, '');

        _ExperimentLoader.update(url, dataToBeSend, _$q.defer());

        $httpBackend.flush();
   });

   it("It should test addStage method", function() {

        var $scope = {
            stage: {
                id: 100,
            },
            protocol: {
                protocol: {
                    id: 10
                }
            }
        };

        var type = "Cycling";

        var url = "/protocols/" + $scope.protocol.protocol.id + "/stages";

        $httpBackend.expectPOST(url).respond(200);
        _ExperimentLoader.addStage($scope, type);
        $httpBackend.flush();
   });

   it("It should test addStage method, when request fail", function() {

        var $scope = {
            stage: {
                id: 100,
            },
            protocol: {
                protocol: {
                    id: 10
                }
            }
        };

        var type = "Cycling";

        var url = "/protocols/" + $scope.protocol.protocol.id + "/stages";

        $httpBackend.expectPOST(url).respond(502);
        _ExperimentLoader.addStage($scope, type);
        $httpBackend.flush();
   });

   it("It should test moveStage method", function() {

        var id = 10, prev_id = 9;
        var url = "/stages/" + id + "/move";

        $httpBackend.expectPOST(url).respond(200);

        _ExperimentLoader.moveStage(id, prev_id);
        $httpBackend.flush();
   });

   it("It should test moveStage method, when request fail", function() {

        var id = 10, prev_id = 9;
        var url = "/stages/" + id + "/move";

        $httpBackend.expectPOST(url).respond(500);

        _ExperimentLoader.moveStage(id, prev_id);
        $httpBackend.flush();
   });

   it("It should test saveCycle method", function() {

        var $scope = {
            stage: {
                num_cycles: 10,
                id: 132
            }
        };

        var url = "/stages/"+ $scope.stage.id;

        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.saveCycle($scope);
        $httpBackend.flush();
   });

   it("It should test changeStartOnCycle method", function() {

        var $scope = {
            stage: {
                id: 100,
                auto_delta_start_cycle: 10
            }
        };

        var url = "/stages/"+ $scope.stage.id;
        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.changeStartOnCycle($scope);
        $httpBackend.flush();
   });

   it("It should test updateAutoDelata method", function() {

        var $scope = {
            stage: {
                id: 100,
                auto_delta: 10
            }
        };

        var url = "/stages/"+ $scope.stage.id;
        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.updateAutoDelata($scope);
        $httpBackend.flush();

   });

   it("It should test moveStep method", function() {

        var id = 100;
        var prev_id = 10;
        var stage_id = 20;
        var url = "/steps/" + id + "/move";

        $httpBackend.expectPOST(url).respond(200);
        _ExperimentLoader.moveStep(id, prev_id, stage_id);
        $httpBackend.flush();
   });

   it("It should test moveStep method, when  request fail", function() {

        var id = 100;
        var prev_id = 10;
        var stage_id = 20;
        var url = "/steps/" + id + "/move";

        $httpBackend.expectPOST(url).respond(500);
        _ExperimentLoader.moveStep(id, prev_id, stage_id);
        $httpBackend.flush();
   });

   it("It should test changeTemperature method", function() {

        var $scope = {
            step: {
                id: 10,
                temperature: 45
            }
        };

        var url = "/steps/" + $scope.step.id;
        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.changeTemperature($scope);
        $httpBackend.flush();
   });

   it("It should test addStep method", function() {

        var $scope = {
            stage: {
                id: 10
            },
            step: {
                id: 12
            }
        };
        var stageId = $scope.stage.id;
        var url = "/stages/"+ stageId +"/steps";
        $httpBackend.expectPOST(url).respond(200);
        _ExperimentLoader.addStep($scope);
        $httpBackend.flush();

   });

   it("It should test addStep method, when request fails", function() {

        var $scope = {
            stage: {
                id: 10
            },
            step: {
                id: 12
            }
        };
        var stageId = $scope.stage.id;
        var url = "/stages/"+ stageId +"/steps";
        $httpBackend.expectPOST(url).respond(500);
        _ExperimentLoader.addStep($scope);
        $httpBackend.flush();

   });

   it("It should test deleteStep method", function() {

        var $scope = {
            step: {
                id: 10
            }
        };

        var url = "/steps/" + $scope.step.id;
        $httpBackend.expectDELETE(url).respond(200);
        _ExperimentLoader.deleteStep($scope);
        $httpBackend.flush();

   });

   it("It should test deleteStep method, when request fails", function() {

        var $scope = {
            step: {
                id: 10
            }
        };

        var url = "/steps/" + $scope.step.id;
        $httpBackend.expectDELETE(url).respond(500);
        _ExperimentLoader.deleteStep($scope);
        $httpBackend.flush();

   });

   it("It should test gatherDuringStep method", function() {

        var $scope = {
            step: {
                id: 10,
                collect_data: true
            }
        };

        var url =  "/steps/" + $scope.step.id;

        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.gatherDuringStep($scope);
        $httpBackend.flush();
   });

   it("It should test gatherDataDuringRamp method", function() {

        var $scope = {
            step: {
                id: 10,
                ramp: {
                    collect_data: true
                }
            }
        };

        var url = "/ramps/" + $scope.step.id;
        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.gatherDataDuringRamp($scope);
        $httpBackend.flush();

   });

   it("It should changeRampSpeed method", function() {

        var $scope = {
            step: {
                id: 10,
                ramp: {
                    rate: 10,
                    collect_data: true
                }
            }
        };

        var url = "/ramps/" + $scope.step.id;
        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.changeRampSpeed($scope);
        $httpBackend.flush();
   });

   it("It should test changeHoldDuration method", function() {

        var $scope = {
            step: {
                id: 10,
                hold_time: 400,
            }
        };

        var url = "/steps/" + $scope.step.id;
        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.changeHoldDuration($scope);
        $httpBackend.flush();

   });

   it("It should test saveName mathod", function() {

        var $scope = {
            step: {
                id: 10,
                name: "Step1"
            }
        };

        var url = "/steps/" + $scope.step.id;
        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.saveName($scope);
        $httpBackend.flush();
   });

   it("It should test changeDeltaTemperature method", function() {

        var $scope = {
            step: {
                id: 10,
                delta_temperature: 25
            }
        };

        var url = "/steps/" + $scope.step.id;
        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.changeDeltaTemperature($scope);
        $httpBackend.flush();
   });

   it("It should test changeDeltaTime method", function() {

        var $scope = {
            step: {
                id: 10,
                delta_duration_s: 25
            }
        };

        var url = "/steps/" + $scope.step.id;
        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.changeDeltaTime($scope);
        $httpBackend.flush();
   });

   it("It should test changePause method", function() {

        var $scope = {
            step: {
                id: 10,
                pause: true
            }
        };

        var url = "/steps/" + $scope.step.id;

        $httpBackend.expectPUT(url).respond(200);
        _ExperimentLoader.changePause($scope);
        $httpBackend.flush();
   });
});