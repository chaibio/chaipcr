describe("Testing arrow directive", function() {

    var _$rootScope, _$scope, _allowAdminToggle, _$compile, httpMock, compiledScope, _ExperimentLoader, _canvas;
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
            httpMock = $injector.get('$httpBackend');
            
            httpMock.expectGET("http://localhost:8000/status").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/wlan").respond("NOTHING");
            httpMock.expectGET("http://localhost:8000/network/eth0").respond("NOTHING");
            httpMock.whenGET("/experiments/10").respond("NOTHING");

            var elem = angular.element('<arrow class="previous" action="previous" ng-click="arrowClicked()"></arrow>');
            var compiled = _$compile(elem)(_$scope);
            _$scope.$digest();
            compiledScope = compiled.scope();

        });
    });

    it("It should test init", function() {

        angular.element('.previous').click();
        expect(1).toEqual(1);
    });

    it("It should test manageNext method", function() {

        var step = {
            nextStep: {
                circle: {
                    manageClick: function() {},

                }
            }
        };
        
        compiledScope.applyValues = function() {

        };
        spyOn(compiledScope, "applyValues").and.returnValue(true);
        
        spyOn(step.nextStep.circle, "manageClick").and.returnValue(true);

        compiledScope.manageNext(step);
        expect(step.nextStep.circle.manageClick).toHaveBeenCalled();
        expect(compiledScope.applyValues).toHaveBeenCalled();
    });

    it("It should test manageNext method, when step is the last one in the stage", function() {

        var step = {
            nextStep: null,
            parentStage: {
                nextStage: {
                    childSteps: [
                        {
                            circle: {
                                manageClick: function() {}
                            }
                        }
                    ]
                }
            }
        };

        compiledScope.applyValuesFromOutSide = function() {

        };

        spyOn(compiledScope, "applyValuesFromOutSide").and.returnValue(true);
        spyOn(step.parentStage.nextStage.childSteps[0].circle, "manageClick").and.returnValue(true);

        compiledScope.manageNext(step);

        expect(step.parentStage.nextStage.childSteps[0].circle.manageClick).toHaveBeenCalled();
        expect(compiledScope.applyValuesFromOutSide).toHaveBeenCalled();
    });

    it("It should test manageNext method, when step is the lastStep", function() {

        var step = {
            nextStep: null,
            nextStage: null,
            parentStage: {
                previousStage: null,
                childSteps: [
                    {
                        circle: {
                            manageClick: function() {}
                        }
                    }
                ]
            }
        };

        compiledScope.applyValues = function() {

        };

        spyOn(compiledScope, "applyValues").and.returnValue(true);
        spyOn(step.parentStage.childSteps[0].circle, "manageClick").and.returnValue(true);
        
        compiledScope.manageNext(step);

        expect(compiledScope.applyValues).toHaveBeenCalled();
        expect(step.parentStage.childSteps[0].circle.manageClick).toHaveBeenCalled();

    });

    it("It should test manageNext method, when step is the lastStep", function() {

        var step = {
            
            parentStage: {
                previousStage: {
                    previousStage: null,
                    childSteps: [
                        {
                            circle: {
                                manageClick: function() {}
                            }
                        }
                    ]
                }, 
            }
        };

        compiledScope.applyValues = function() {

        };

        var targetStage = step.parentStage.previousStage.childSteps[0].circle;
        spyOn(compiledScope, "applyValues").and.returnValue(true);
        spyOn(targetStage, "manageClick").and.returnValue(true);
        
        compiledScope.manageNext(step);

        expect(compiledScope.applyValues).toHaveBeenCalled();
        expect(targetStage.manageClick).toHaveBeenCalled();

    });

    it("It should test managePrevious method", function() {

        var step = {
            previousStep: {
                circle: {
                    manageClick: function() {},
                }
            }
        };

        compiledScope.applyValues = function() {

        };

        spyOn(compiledScope, "applyValues").and.returnValue(true);     
        spyOn(step.previousStep.circle, "manageClick").and.returnValue(true);
        
        compiledScope.managePrevious(step);

        expect(compiledScope.applyValues).toHaveBeenCalled();
        expect(step.previousStep.circle.manageClick).toHaveBeenCalled();
    });
});