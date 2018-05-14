describe("Testing action directive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas, _$timeout, _$uibModal,
    _alerts, _popupStatus, _TimeService, _addStageService, _$state, _NetworkSettingsService, _editModeService;

    beforeEach(function() {

        module("ChaiBioTech", function($provide) {
            $provide.value('IsTouchScreen', function () {});
            /*$provide.value('$state', {
                is: function() {
                    return true;
                }
            });*/
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
            _TimeService = $injector.get('TimeService');
            _addStageService = $injector.get('addStageService');
            _$state = $injector.get('$state');
            _editModeService = $injector.get('editModeService');
            _$state.is = function() {
                return true;
            };
            _$state.params = {
                name: "chai"
            };

            _NetworkSettingsService = $injector.get('NetworkSettingsService');

            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond("NOTHING");

            var stage = {
                auto_delta: true
            };

            var step = {
                delta_duration_s: 10,
                hold_time: 20,
                pause: true
            };

            var elem = angular.element('<actions></actions>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.show = true;
            _$scope.$digest();
            compiledScope = compiled.scope();
            
        });
    });


    it("It should test initial values", function() {
        console.log(compiledScope);
        expect(compiledScope.actionPopup).toEqual(false);
        expect(compiledScope.infiniteHoldStep).toEqual(false);
        expect(compiledScope.editStageMode).toEqual(false);
        expect(compiledScope.editStageText).toEqual("EDIT STAGES");
    });

    it("It should test dataLoaded broadcast", function() {

        compiledScope.$broadcast('dataLoaded');
        compiledScope.actionPopup = false;
        compiledScope.$digest();
        expect(_popupStatus.popupStatusAddStage).toEqual(compiledScope.actionPopup);
    });

    it("It should test dataLoaded broadcast and change pause", function() {

        compiledScope.$broadcast('dataLoaded');

        compiledScope.step = {
            pause: false
        };
        
        compiledScope.$digest();

        compiledScope.step = {
            pause: true
        };
        compiledScope.$digest();

        //expect(compiledScope.popAction).toEqual("Remove");
    });

    it("It should test dataLoaded broadcast and change in step", function() {

        compiledScope.fabricStep = {
            circle: {
                holdTime: {
                    text: "∞"
                }
            }

        };

        compiledScope.$broadcast('dataLoaded');

        compiledScope.step = {
            id: 10
        };

        compiledScope.$digest();

        expect(compiledScope.infiniteHoldStep).toEqual(true);

    });

    it("It should test dataLoaded broadcast and change in step when containInfiniteStep return true", function() {

        compiledScope.fabricStep = {
            circle: {
                holdTime: {
                    text: "10"
                }
            },
            parentStage: {

            }
        };

        spyOn(compiledScope, "containInfiniteStep").and.returnValue(true);
        compiledScope.$broadcast('dataLoaded');

        compiledScope.step = {
            id: 10
        };

        compiledScope.$digest();

        expect(compiledScope.containInfiniteStep).toHaveBeenCalled();
        expect(compiledScope.infiniteHoldStep).toEqual(false);
        expect(compiledScope.infiniteHoldStage).toEqual(true);

    });

    it("It should test dataLoaded broadcast and change in step when containInfiniteStep return false", function() {

        compiledScope.fabricStep = {
            circle: {
                holdTime: {
                    text: "10"
                }
            },
            parentStage: {

            }
        };

        spyOn(compiledScope, "containInfiniteStep").and.returnValue(false);
        compiledScope.$broadcast('dataLoaded');

        compiledScope.step = {
            id: 10
        };

        compiledScope.$digest();

        expect(compiledScope.containInfiniteStep).toHaveBeenCalled();
        expect(compiledScope.infiniteHoldStep).toEqual(false);
        expect(compiledScope.infiniteHoldStage).toEqual(false);

    });

    it("It should test addStage_ method", function() {

        compiledScope.summaryMode = false;
        compiledScope.actionPopup = true;
        compiledScope.$digest();
        compiledScope.addStage_();

        expect(compiledScope.actionPopup).toEqual(false);

    });

    it("It should test containInfiniteStep method when its not infiniteHold", function() {

        var stage = {
            childSteps: [
                {
                    id: 0,
                    circle: {
                        holdTime: {
                            text: "10"
                        }
                    }
                }
            ]
        };

        var retVal = compiledScope.containInfiniteStep(stage);

        expect(retVal).toEqual(false);
    
    });

    it("It should test containInfiniteStep method when its infiniteHold", function() {

        var stage = {
            childSteps: [
                {
                    id: 0,
                    circle: {
                        holdTime: {
                            text: "∞"
                        }
                    }
                }
            ]
        };

        var retVal = compiledScope.containInfiniteStep(stage);

        expect(retVal).toEqual(true);
    
    });

    it("It should test addStep method", function() {

        compiledScope.fabricStep = {
            parentStage: {
                addNewStep: function() {

                }
            }
        };

        _ExperimentLoader.addStep = function() {
            var data = {

            };

            return {
                then: function(callback) {
                    callback(data);
                }
            };
        };
        spyOn(_ExperimentLoader, "addStep").and.callThrough();
        spyOn(compiledScope.fabricStep.parentStage, "addNewStep").and.returnValue(true);
        compiledScope.infiniteHoldStep = false;
        compiledScope.summaryMode = false;
        compiledScope.$digest();

        compiledScope.addStep();

        expect(_ExperimentLoader.addStep).toHaveBeenCalled();
        expect(compiledScope.fabricStep.parentStage.addNewStep).toHaveBeenCalled();

    });

    it("It should test deleteStep method", function() {

        _ExperimentLoader.deleteStep = function() {

            var data = {};
            return {
                then: function(callback) {
                    callback(data);
                }
            };
        };

        compiledScope.fabricStep = {
           parentStage: {
               deleteStep: function() {

               }
           } 
        };

        spyOn(_ExperimentLoader, "deleteStep").and.callThrough();
        spyOn(compiledScope.fabricStep.parentStage, "deleteStep").and.returnValue(true);

        compiledScope.deleteStep();

        expect(_ExperimentLoader.deleteStep).toHaveBeenCalled();
        expect(compiledScope.fabricStep.parentStage.deleteStep).toHaveBeenCalled();
    });

    it("It should test editStage method when editStageMode === false", function() {

        _editModeService.editStageMode = function() {

        };

        spyOn(_editModeService, "editStageMode").and.callThrough();

        compiledScope.editStageMode = false;

        compiledScope.editStage();

        expect(compiledScope.editStageText).toEqual("DONE");
        expect(_editModeService.editStageMode).toHaveBeenCalled();
    });

    it("It should test editStage method when editStageMode === false", function() {

        _editModeService.editStageMode = function() {

        };

        spyOn(_editModeService, "editStageMode").and.callThrough();

        compiledScope.editStageMode = true;

        compiledScope.editStage();

        expect(compiledScope.editStageText).toEqual("EDIT STAGES");
        expect(_editModeService.editStageMode).toHaveBeenCalled();
    });

    it("It should test addPause method", function() {

        _ExperimentLoader.changePause = function() {
            var data = {};
            return {
                then: function(callback) {
                    callback(data);
                }
            };
        };

        spyOn(_ExperimentLoader, "changePause").and.callThrough();

        compiledScope.summaryMode = false;
        compiledScope.infiniteHoldStep = false;
        compiledScope.step = {
            collect_data: false,
            pause: false
        };

        compiledScope.$digest();

        compiledScope.addPause();

        expect(_ExperimentLoader.changePause).toHaveBeenCalled();
        expect(compiledScope.step.pause).toEqual(true);
    });
});