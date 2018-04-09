describe("Testing general directive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
        });

        inject(function($injector) {

            _$rootScope = $injector.get('$rootScope');
            _$scope = _$rootScope.$new();
            _$compile = $injector.get('$compile');
            _ExperimentLoader = $injector.get('ExperimentLoader');
            _canvas = $injector.get('canvas');
            _$timeout = $injector.get('$timeout');
            _HomePageDelete = $injector.get('HomePageDelete');
            _$uibModal = $injector.get('$uibModal');
            _alerts = $injector.get('alerts');
            _popupStatus = $injector.get('popupStatus');
            httpMock = $injector.get('$httpBackend');
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond("NOTHING");

            var stage = {
                auto_delta: true
            };

            var step = {
                delta_duration_s: 10
            };
            var elem = angular.element('<general></general>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.scope();
            
        });
    }); 

    it("It should test initial values", function() {
        expect(compiledScope.stageNoCycleShow).toEqual(false);
        expect(compiledScope.popUp).toEqual(false);
        expect(compiledScope.showCycling).toEqual(false);
        expect(compiledScope.warningMessage).toEqual("You have entered a wrong value. Please make sure you enter digits in the format HH:MM:SS.");
        expect(compiledScope.stepNameShow).toEqual(false);
    });

    it("It should test dataLoaded event", function() {

        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();

        compiledScope.$emit("dataLoaded");

        expect(compiledScope.delta_state).toEqual("ON");
    });

    it("It should test dataLoaded event and popUp change", function() {

        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();
        compiledScope.$emit("dataLoaded");
        
        compiledScope.popUp = true;
        compiledScope.$digest();
        expect(_popupStatus.popupStatusGatherData).toEqual(compiledScope.popUp);

    });

    it("It should test dataLoaded event and step.id change", function() {

        spyOn(_$rootScope, "$broadcast").and.returnValue(true);
        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();
        compiledScope.$emit("dataLoaded");

        compiledScope.fabricStep = {};
        
        compiledScope.step = {
            id: 100
        };
        compiledScope.$digest();

        expect(_$rootScope.$broadcast).toHaveBeenCalled();
    });

    it("It should test dataLoaded event and stage.stage_type change when stage_type cycling", function() {

        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();
        compiledScope.$emit("dataLoaded");

        compiledScope.stage = {
            stage_type: "cycling",
            num_cycles: 10
        };

        compiledScope.$digest();

        expect(compiledScope.showCycling).toEqual(true);
        expect(compiledScope.cycleNoBackup).toEqual(10);
    });

    it("It should test dataLoaded event and stage.stage_type change when stage_type not cycling", function() {

        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();
        compiledScope.$emit("dataLoaded");

        compiledScope.stage = {
            stage_type: "holding",
            num_cycles: 10
        };

        compiledScope.$digest();

        expect(compiledScope.showCycling).toEqual(false);
        
    });

    it("It should test dataLoaded event and holdTime.text change and its ∞", function() {

        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();
        compiledScope.$emit("dataLoaded");

        compiledScope.fabricStep = {
            circle: {
                holdTime: {
                    text: "∞"
                } 
            }
        };

        compiledScope.$digest();
        
        expect(compiledScope.infiniteHoldStep).toEqual(true);
        expect(compiledScope.infiniteHoldStage).toEqual(true);
    });

    it("It should test dataLoaded event and holdTime.text change and its not ∞", function() {

        compiledScope.stage = {
            auto_delta: true
        };

        compiledScope.$digest();
        compiledScope.$emit("dataLoaded");

        compiledScope.fabricStep = {
            circle: {
                holdTime: {
                    text: "100"
                } 
            }
        };

        compiledScope.$digest();
        
        expect(compiledScope.infiniteHoldStep).toEqual(false);
        expect(compiledScope.infiniteHoldStage).toEqual(false);
    });

    it("It should test clickOnField method", function() {

        spyOn($.fn, "val").and.returnValue("");
        spyOn($.fn, "width").and.returnValue({
            parent: function() {
                return {
                    width: function() {
                        return 25;
                    }
                };
            }
        });
        
        spyOn($.fn, "parent").and.returnValue({
            width: function() {
                return 25;
            }
        });

        compiledScope.clickOnField("stepNameShow", "general");

        expect($.fn.val).toHaveBeenCalled();
        expect($.fn.parent).toHaveBeenCalled();
    });

    it("It should test saveCycle", function() {

        spyOn($.fn, "val").and.returnValue(10);
        spyOn(_$rootScope, "$broadcast").and.returnValue(true);
        spyOn(_ExperimentLoader, "saveCycle").and.returnValue({
            then: function(callback) {
                callback();
            }
        });

        compiledScope.stage = {
            num_cycles: 12,
            auto_delta_start_cycle: 3
        };

        compiledScope.saveCycle();

        expect(compiledScope.stageNoCycleShow).toEqual(false);
        expect(_ExperimentLoader.saveCycle).toHaveBeenCalled();
        expect(_$rootScope.$broadcast).toHaveBeenCalled();
    });

    it("It should test saveCycle when onClickValue === scope.stage.num_cycles", function() {

        spyOn($.fn, "val").and.returnValue(15);
        spyOn(_$rootScope, "$broadcast").and.returnValue(true);
        spyOn(_ExperimentLoader, "saveCycle").and.returnValue({
            then: function(callback) {
                callback();
            }
        });

        spyOn(_alerts, "showMessage").and.returnValue(true);
        compiledScope.stage = {
            num_cycles: 10,
            auto_delta_start_cycle: 15
        };
        
        compiledScope.$digest();

        compiledScope.clickOnField("stepNameShow", "general");
        compiledScope.saveCycle();

        expect(compiledScope.stageNoCycleShow).toEqual(false);
        expect(_ExperimentLoader.saveCycle).not.toHaveBeenCalled();
        expect(_$rootScope.$broadcast).not.toHaveBeenCalled();
        expect(_alerts.showMessage).toHaveBeenCalled();
    });

    it("It should test changeDelta method", function() {

        compiledScope.stage = {
            stage_type: "cycling",
            auto_delta: true,

        };

        spyOn(_ExperimentLoader, "updateAutoDelata").and.returnValue({
            then: function(callback) {
                callback();
            }
        });

        compiledScope.$digest();

        compiledScope.changeDelta();

        expect(compiledScope.delta_state).toEqual("OFF");
        expect(_ExperimentLoader.updateAutoDelata).toHaveBeenCalled();
    });

    it("It should test changeDelta method when stage_type not cycling", function() {

        compiledScope.stage = {
            stage_type: "holding",
            auto_delta: true,

        };

        spyOn(_ExperimentLoader, "updateAutoDelata").and.returnValue({
            then: function(callback) {
                callback();
            }
        });

        spyOn(_alerts, "showMessage").and.returnValue(true);
        compiledScope.$digest();

        compiledScope.changeDelta();

        expect(_ExperimentLoader.updateAutoDelata).not.toHaveBeenCalled();
        expect(_alerts.showMessage).toHaveBeenCalled();
    });

    it("it should test saveStepName method", function() {

        compiledScope.step = {
            name: "bingo"
        };

        spyOn(_ExperimentLoader, "saveName").and.returnValue(true);
        
        compiledScope.$digest();

        compiledScope.saveStepName();

        expect(compiledScope.stepNameShow).toEqual(false);
        expect(_ExperimentLoader.saveName).toHaveBeenCalled();
    });

    it("It should test changeDuringStep method", function() {

        spyOn(_ExperimentLoader, "gatherDuringStep").and.returnValue(true);

        compiledScope.popUp = false;
        compiledScope.step = {
            collect_data: false
        };

        compiledScope.$digest();

        compiledScope.changeDuringStep();

        expect(compiledScope.popUp).toEqual(true);
        expect(compiledScope.step.collect_data).toEqual(true);
        expect(_ExperimentLoader.gatherDuringStep).toHaveBeenCalled();
    });

    it("It should test hidePopup method", function() {

        compiledScope.popUp = true;

        compiledScope.$digest();

        compiledScope.hidePopup();

        expect(compiledScope.popUp).toEqual(false);
    });

    it("It should test changeDuringRamp method", function() {

        spyOn(_ExperimentLoader, "gatherDataDuringRamp").and.returnValue(true);
        compiledScope.popUp = false;
        compiledScope.step = {
            ramp: {
                collect_data: false
            }
        };

        compiledScope.$digest();

        compiledScope.changeDuringRamp();
        
        expect(_ExperimentLoader.gatherDataDuringRamp).toHaveBeenCalled();
        expect(compiledScope.popUp).toEqual(true);
        expect(compiledScope.step.ramp.collect_data).toEqual(true);
    });
});