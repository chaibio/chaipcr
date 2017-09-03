describe("Testing add-step-service", function() {

    var _addStepService, _constants, _correctNumberingService, _step, _circleManager;
    beforeEach(function() {
        
        module('ChaiBioTech', function($provide) {

            $provide.value('step', function() {
                return {
                    render: function() {}
                };
            });

        });

        inject(function($injector) {
            _addStepService = $injector.get('addStepService');
            _circleManager = $injector.get('circleManager');
            _constants = $injector.get('constants');
            _correctNumberingService = $injector.get("correctNumberingService");
            _step = $injector.get("step");
        });
    });

    it("It should test addNewStep method", function() {

        var stage = {
            setNewWidth: function() {},
            moveAllStepsAndStages: function() {},
            parent: {
                allStepViews: {
                    splice: function() {},
                }
            },
            childSteps: [
                {
                    ordealStatus: 1
                },
            ],
            model: {
                steps: {
                    splice: function() {}
                }
            }
        };

        var stepData = {
            step: {

            }
        };

        var currentStep = {
            index: 1,
            ordealStatus: 2
        };

        var $scope = {

        }; 

        spyOn(stage, 'setNewWidth');
        spyOn(stage, 'moveAllStepsAndStages');
        spyOn(stage.childSteps, "splice");
        spyOn(stage.model.steps, "splice");
        spyOn(stage.parent.allStepViews, "splice");

        spyOn(_addStepService, "configureStep").and.returnValue(true);
        spyOn(_addStepService, "postAddStep").and.returnValue(true);

        _addStepService.addNewStep(stage, stepData, currentStep, $scope);

        expect(stage.setNewWidth).toHaveBeenCalled();
        expect(stage.moveAllStepsAndStages).toHaveBeenCalled();
        expect(stage.childSteps.splice).toHaveBeenCalled();
        expect(stage.model.steps.splice).toHaveBeenCalled();
        expect(stage.parent.allStepViews.splice).toHaveBeenCalled();
        expect(_addStepService.configureStep).toHaveBeenCalled();
        expect(_addStepService.postAddStep).toHaveBeenCalled();
    });

    it("It should test addNewStep method when currentStep = null", function() {
        
        var stage = {
            setNewWidth: function() {},
            moveAllStepsAndStages: function() {},
            parent: {
                allStepViews: {
                    splice: function() {},
                }
            },
            childSteps: [
                {
                    ordealStatus: 1
                },
            ],
            model: {
                steps: {
                    splice: function() {}
                }
            }
        };

        var stepData = {
            step: {

            }
        };

        var currentStep = null;

        var $scope = {

        }; 

        spyOn(stage, 'setNewWidth');
        spyOn(stage, 'moveAllStepsAndStages');
        spyOn(stage.childSteps, "splice");
        spyOn(stage.model.steps, "splice");
        spyOn(stage.parent.allStepViews, "splice");

        spyOn(_addStepService, "configureStep").and.returnValue(true);
        spyOn(_addStepService, "postAddStep").and.returnValue(true);

        _addStepService.addNewStep(stage, stepData, currentStep, $scope);


    });
});